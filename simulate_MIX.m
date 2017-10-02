function C = simulate_MIX(data,stimuli,sequence,y,nr_ept,A,gamma,trials)
%% This function simulates/trains an unsupervised mixing classifier
%
% Terminology:
% The series of flashes which is used to spell one character is called a
% trial. An epoch is called the segmented interval around a highlighting event.
% Furthermore, the following names are used:
%
% nr_commands: -- Number of different possible commands (e.g. number of
%                 symbols the user could spell in an ERP paradigm
% N         --  Total number of epochs
% nr_ept    --  Number of epochs per trial
% nr_tpt    --  Number of targets per trial
% nr_trials --  Number of trials
% feat_dim  --  Feature dimensionality
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input / Data Format:
%
% data      --  Array of size (N X feat_dim) feature matrix
% stimuli   --  Array of size (nr_commands X N) matrix, BINARY ARRAY
%               to indicate whether command was intensified during stimulus s_i
% sequence  --  ARRAY of length N indicating whether a
%               stimulus k belongs to sequence 1 or 2
% y         --  [OPTIONAL]. BOOLEAN ARRAY of length N indicating whether
%               stimulus k was a target (TRUE) or non-target (FALSE)
%               Only used for statistics, not for training the classifier
% nr_ept    --  Number of epochs (highlighting events) to spell one character
% A         --  Mixing matrix for LLP
% gamma     --  Value deciding about the decoder:
%                   -1 : MIX method
%                    0 : EM-Method
%                   +1 : LLP-Method
% trials    -- Which trials should be analysed, e.g. trials = 10:20
%              analyses the spelling attempts for characters 10 to 20
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Background:
% The Expectation-Maximization (EM) Algorithm was implemented by Pieter-Jan Kindermans:
%
% Kindermans, P. J., Verstraeten, D., & Schrauwen, B. (2012).
% A bayesian model for exploiting application constraints to enable
% unsupervised training of a P300-based BCI. PloS one, 7(4), e33758.
%
% The learning from label proportion (LLP) idea is based on work by David Hübner et al.:
%
% Hübner, D., Verhoeven, T., Schmid, K., Müller, K. R.,
% Tangermann, M., & Kindermans, P. J. (2017).
% Learning from label proportions in brain-computer interfaces:
% Online unsupervised learning with guarantees. PloS one, 12(4), e0175856.
%
% The MIX-Method was implemented by Thibault Verhoeven:
%
% Verhoeven, T., Hübner, D., Tangermann, M., Müller, K. R.,
% Dambre, J., & Kindermans, P. J. (2017).
% Improving zero-training brain-computer interfaces by mixing model estimators.
% Journal of neural engineering, 14(3), 036021.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function was created by
% David Hübner <david.huebner@blbt.uni-freiburg.de>
%
% Jul, 2017

% Adjustable parameters
nr_em_steps = 5;        % Number of EM-steps [Default = 5]

% Internal parameters
nr_tpt = 16;            % Number of targets per trial
A_inv = inv(A);
A_inv2 = A_inv.^2;
nr_commands = size(stimuli,1);
[nr_total,feat_dim] = size(data);

% Select specified trials in case this option was chosen
if ~isempty(trials)
    idx = [];
    for t=trials
        idx = [idx (t-1)*nr_ept+1:t*nr_ept];
    end
    data = data(idx,:);
    if ~isempty(y)
        y    = y(:,idx);
    end
    stimuli = stimuli(:,idx);
    nr_trials = length(trials);
else
    assert( rem(nr_total,nr_ept)==0, 'Number of data points divided by epochs per trial is not an integer');
    nr_trials = nr_total/nr_ept;
    trials = 1:nr_trials;
end

disp('-------Start simulated online experiment!--------')
disp('The classifier starts from a random initalization and is retrained after each trial.');
disp('The binary target-vs-non target area under the curve (AUC) on all data ');
disp('until the current trial is then reported, if label information are available.');
disp('Additionally, the mixing coefficient for the target and non-target classes are reported.')
fprintf('-----------------------------------------------------\n\n');

% Init classifier
C = init_classifier(randn(feat_dim,1),feat_dim,nr_commands,nr_ept,nr_tpt);

% Loop over new trials
for c_i = 1:nr_trials
    fprintf('Trial %3d. ', trials(c_i));
    tic();
    N = c_i*nr_ept;
    
    % Clear stored data fields (this is necessary becasuse the data is
    % normalized on all data until the current trial)
    C.classifier = clear_fields(C.classifier,feat_dim);
    
    % Perform global normalization on all data until current trial
    current_data = data(1:N,:);
    current_stim = stimuli(:,1:N);
    current_sequence = sequence(1:N,1);
    
    global_mu = mean(current_data,1);
    global_std = std(current_data,1,1);
    
    data_norm = current_data-repmat(global_mu,N,1);
    data_norm = data_norm./repmat(global_std,N,1);
    
    % Split data into trials
    data_list = {};
    stimuli_list = {};
    
    for j = 1:c_i
        data_list{end+1}    = data_norm((j-1)*nr_ept+1:j*nr_ept,:);
        stimuli_list{end+1} = current_stim(:,(j-1)*nr_ept+1:j*nr_ept);
    end
    
    % Add all letters
    C.classifier = classifier_mix_add_letter(C.classifier,data_list,stimuli_list);
    
    % -----Determine covariance matrix with Ledoit-Wolf shrinkage  ------ %
    % as implemented for BCI by B. Blankertz et al., NeuroImage, 2010.
    % Yields an analytical shrinkage parameter lamb and the regularized
    % covariance matrix C.classifier.Sigma
    nu = mean(diag(C.classifier.XTX));
    T =  nu*eye(feat_dim,feat_dim);
    numerator = sum(sum(C.classifier.X2TX2-1.0*((C.classifier.XTX.^2)/N)));
    denominator = sum(sum((C.classifier.XTX-T).^2));
    lamb = (N/(N-1))*numerator/denominator;
    lamb = max([0,min([1,lamb])]);
    C.classifier.Sigma = ((1-lamb)*C.classifier.XTX+lamb*T)/(N-1);
    % Determine whitening matrix
    [V,D] = eig(C.classifier.Sigma);
    C.classifier.Whiten = V*(diag(diag(D).^(-0.5)));
    
    % ----------- Estimate Means with LLP  ----------- %
    N1 = sum(current_sequence==1);
    N2 = sum(current_sequence==2);
    
    % Averaging sequences
    average_O1 = mean(data_norm(current_sequence==1,:),1);
    average_O2 = mean(data_norm(current_sequence==2,:),1);
    
    % Solution of the linear system
    llp_mean_pos =(A_inv(1,1)*average_O1+A_inv(1,2)*average_O2)';
    llp_mean_neg =(A_inv(2,1)*average_O1+A_inv(2,2)*average_O2)';
    
    % Calculate variance for mixing it with EM
    var_O1 = var(data_norm(current_sequence==1,:)*C.classifier.Whiten,1,1);
    var_O2 = var(data_norm(current_sequence==2,:)*C.classifier.Whiten,1,1);
    
    llp_var_pos = sum((A_inv2(1,1)/N1)*var_O1 + (A_inv2(1,2)/N2)*var_O2);
    llp_var_neg = sum((A_inv2(2,1)/N1)*var_O1 + (A_inv2(2,2)/N2)*var_O2);
    
    % ----------- Estimate Means with EM  ----------- %
    % EM Iterations
    for em_it = 1:nr_em_steps
        C.classifier = classifier_mix_expectation(C.classifier);
        C.classifier = classifier_mix_maximization(C.classifier);
    end
    C.classifier = classifier_mix_expectation(C.classifier);
    
    %Extract EM means
    em_mean_pos = C.classifier.em_pos;
    em_mean_neg = C.classifier.em_neg;
    
    % ----------- Mix Mean Estimations  ----------- %
    % gamma = -1 ==> MIX means
    % gamma =  0 ==> EM-algorithm
    % gamma =  1 ==> LLP-algorithm
    if gamma == -1
        [EM_var_pos, EM_var_neg] = compute_EM_variance(C,data_norm,em_mean_pos,em_mean_neg);
        pos_est_diff = C.classifier.Whiten'*(em_mean_pos - llp_mean_pos);
        neg_est_diff = C.classifier.Whiten'*(em_mean_neg - llp_mean_neg);
        
        gamma_pos = max([0,min([1,0.5*((EM_var_pos-llp_var_pos)/dot(pos_est_diff',pos_est_diff)+1)])]);
        gamma_neg = max([0,min([1,0.5*((EM_var_neg-llp_var_neg)/dot(neg_est_diff',neg_est_diff)+1)])]);
    else
        gamma_pos = gamma;
        gamma_neg = gamma;
    end
    
    %Mix EM means with LLP based on mixing coefficients gamma
    mean_pos = (1.0-gamma_pos)*em_mean_pos+gamma_pos*llp_mean_pos;
    mean_neg = (1.0-gamma_neg)*em_mean_neg+gamma_neg*llp_mean_neg;
    
    %Update projections with new means
    C.classifier.w = C.classifier.Sigma\(mean_pos-mean_neg); %Sigma^(-1)*(mu_pos-mu_neg)
    
    %******Evaluate******
    projection = classifier_compute_projection(C.classifier,C.classifier.data);  % x^T*w
    
    % Compute AUC if labels are given
    if ~isempty(y)
        label = [y; 1-y];
        total_projection = vertcat(projection{:})';
        auc=loss_rocArea([y(1:length(total_projection)); ...
            1-y(1:length(total_projection))],total_projection);
        C.statistics.auc = [C.statistics.auc auc];
        fprintf('AUC: %.3f%%. ',100*auc);
    end
    fprintf('Gamma_pos: %.3f, Gamma_neg: %.3f. Runtime: %.3fs\n', gamma_pos, gamma_neg, toc());
    
    % Store informative results in C.statistics
    C.statistics.projection{end+1} = projection;
    C.statistics.data_log_likelihood = [C.statistics.data_log_likelihood C.classifier.data_log_likelihood];
    C.statistics.w{end+1} = C.classifier.w;
    C.statistics.probs{end+1} = C.classifier.probs;
    C.statistics.gamma_pos = [C.statistics.gamma_pos gamma_pos];
    C.statistics.gamma_neg = [C.statistics.gamma_neg gamma_neg];
end

fprintf('\n-----------------------------------------------------\n');
disp('Simulation completed.')
disp('Find the final classifier in C.classifier.');
disp('Statistics are saved in C.statistics.');
fprintf('-----------------------------------------------------\n\n');
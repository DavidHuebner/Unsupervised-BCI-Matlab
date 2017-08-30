function classifier=classifier_mix_add_letter(classifier,data,stimuli)
%% Add letter to the classifier
% parameters:
% classifier   --  the classifier struct to which the data has to be added
% data      --  cell_array with per cell  (n_ept x feat_dim) matrix
%               containing the features
% stimuli   --  cell_array with per cell (nr_commands X n_ept) matrix, 
%               BINARY ARRAY to indicate whether command a was intensified
%               during stimulus s
%
% By Pieter-Jan Kindermans, 2014
%
% Modified and commented by david.huebner@blbt.uni-freiburg.de, 2017


% Loop over each character
for c_i = 1:length(data)
    cur_data = data{c_i};
    cur_stimuli = stimuli{c_i};
    
    % Store data and stimuli
    classifier.data{end+1} = cur_data;
    classifier.stimuli{end+1}=cur_stimuli;
    
    % Cache XTY and XTX
    classifier.XTX_list{end+1} = cur_data'*cur_data;
    classifier.XTX = classifier.XTX + cur_data'*cur_data;
    classifier.X2TX2 = classifier.X2TX2 + (cur_data.^2)'*(cur_data.^2);
 
    temp_XTYp = zeros(classifier.feat_dim,classifier.nr_commands);
    temp_XTYn = zeros(classifier.feat_dim,classifier.nr_commands);

    % Loop over all possible selections 
    for a_i =1:classifier.nr_commands
        index = cur_stimuli(a_i,:);
        
        nr_pos = sum(index == 1);
        nr_neg = sum(index == 0);
        
        temp_XTYp(:,a_i) = temp_XTYp(:,a_i) + cur_data(index==1,:)'*(classifier.label(1)*ones(nr_pos,1));
        temp_XTYn(:,a_i) = temp_XTYn(:,a_i) + cur_data(index==0,:)'*(classifier.label(2)*ones(nr_neg,1));
    end

     classifier.XTYp{end+1} = temp_XTYp;
     classifier.XTYn{end+1} = temp_XTYn;   
end
end
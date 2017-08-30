function C = init_classifier(w,feat_dim,nr_commands, nr_ept, nr_tpt)

% The C struct has two fields: "classifier" which is used for storing the
% current data, performing the EM steps, caluclating the projection and
% predicting the attended character and the "statistics" field which is
% storing useful information from all trials

C.classifier = struct();
C.classifier.w = w;
C.classifier.nr_commands = nr_commands;
C.classifier.feat_dim = feat_dim;

% classifier.label are the rescaled target and non-target class labels. 
% One can show that when they are chosen as N/N+ and N/N- respectively,
% that this leads to an equivalence between least square regression and
% linear discriminant analysis in terms of the projection w. For instance,
% in the paradigm of the MIX scenario, there are N+ = 16 targets and N-=52 
% non-targets contained in every 68 symbols.
%
% For more information, see:
% Bishop's Machine learning book, Springer, 2006, Chapter 4.1.5
C.classifier.label = [nr_ept/nr_tpt   -nr_ept/(nr_ept-nr_tpt)];

C.statistics.w_init = w;
C.statistics.gamma_pos = {};
C.statistics.gamma_neg = {};
C.statistics.auc = [];
C.statistics.data_log_likelihood = [];
C.statistics.w = {};
C.statistics.projection = {};
C.statistics.probs = {};
end
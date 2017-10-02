function projection = classifier_compute_projection(classifier,data)
%% Computes w^T*x for each trial
projection = {};
    for d_i = 1:length(data)
        projection{end+1}=data{d_i}*classifier.w;
    end
end
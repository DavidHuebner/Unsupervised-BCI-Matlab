function classifier = clear_fields(classifier,feat_dim)

classifier.data = {};
classifier.stimuli = {};
classifier.XTX_list = {};
classifier.XTYp = {};
classifier.XTYn = {};
classifier.XTX = zeros(feat_dim,feat_dim);
classifier.X2TX2 = zeros(feat_dim,feat_dim);

end
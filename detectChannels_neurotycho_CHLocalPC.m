%detectChannels_neurotycho_CHLocalPC.m

species = 'macaque';
subject = 'George';

root_dir = 'C:\Users\chikayo\lab\hctsa_proj';
save_dir = fullfile(root_dir, 'preprocessed',species,subject);

if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end


%load('Neurotycho_channelLobe.mat','channelLobe','animals','lobeName');
% Neurotycho_channelLobe.mat の場所に合わせて修正
load(fullfile(root_dir, '11_data_raw', 'macaque', 'Stage1', ...
    'Neurotycho_channelLobe.mat'), 'channelLobe', 'animals', 'lobeName');

%result of Neurorycho_channelLobe.m

animalID = find(strcmp(animals, subject));

channel = 1:size(channelLobe,1);
lobeID = channelLobe(channel,animalID);
lobe =cell(numel(channel),1);
lobe(lobeID~=0) = lobeName(lobeID(lobeID~=0));
lobe(lobeID==0) = {'N.A.'};
lobe = categorical(lobe);

nChannelByLobe = 3;
channelsByLobe = []; tgtChannels = [];
for ilobe = 1:numel(lobeName)
    %channelsByLobe{ilobe} = find(strcmp(lobeName{ilobe}, lobeName(:,animalID)))';
    channelsByLobe{ilobe} = find(channelLobe(:,animalID) == ilobe)';
    randIdx = randperm(numel(channelsByLobe{ilobe}));
    tgtChannels = [tgtChannels channelsByLobe{ilobe}(randIdx(1:nChannelByLobe))];
end


if ~exist(save_dir, 'dir')
    mkdir(save_dir);
end

save(fullfile(save_dir,['detectChannels_' subject]) , ...
     'channelsByLobe','tgtChannels','channel','lobe');


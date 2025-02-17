function [ utilityLayerFunctions, utilityHistory, utilityAccessCosts, utilityTimeConstraints, utilityAccessCodesMat, utilityPrereqs, utilityBaseLayers, utilityForms, incomeForms, nExpected, hardSlotCountYN ] = createUtilityLayers(locations, modelParameters, demographicVariables )
%createUtilityLayers defines the different income/utility layers (and the
%functions that generate them)

%utility layers are described in this model by i) a function used to
%generate a utility value, ii) a set of particular codes corresponding to
%access requirements to use this layer, iii) a vector of costs associated
%with each of those codes, and iv) a time constraint explaining the
%fraction of an agent's time consumed by accessing that particular layer.
%all of these variables are generated here.

%at present, individual layer functions are defined as anonymous functions
%of x, y, t (timestep), and n (number of agents occupying the layer).  any
%additional arguments can be fed by varargin.  the key constraint of the
%anonymous function is that whatever is input must be executable in a
%single line of code - if the structure for the layer is more complicated,
%one must either export some of the calculation to an intermediate variable
%that can be fed to a single-line version of the layer function OR revisit
%this anonymous function structure.

%some parameters only relevant to this file - should be moved to parameters
%file once we're sure.  while they are here, they won't be included in
%sensitivity testing
quantiles = 4;
years = 11;
noise = modelParameters.utility_noise;
iReturn = modelParameters.utility_iReturn;
iDiscount = modelParameters.utility_iDiscount;
iYears = modelParameters.utility_iYears;
leadTime = modelParameters.spinupTime;


load([modelParameters.utilityDataPath '/incomeMats_noWinsorize']);

%fix mismatches between HIES dataset names and spatial data
bUnion = strrep(bUnion,'Nawabganj','Chapai Nababganj');
bUnion = strrep(bUnion,'Cox''s bazar','Cox''s Bazar');
bUnion = strrep(bUnion,'Jaipurhat','Joypurhat');
bUnion = strrep(bUnion,'Jhenaidah','Jhenaidaha');
bUnion = strrep(bUnion,'Khagrachari','Khagrachhari');
bUnion = strrep(bUnion,'Maulvibazar','Maulvi Bazar');
bUnion = strrep(bUnion,'Munshigan','Munshiganj');
bUnion = strrep(bUnion,'Panchagar','Panchagarh');

%first entry is a blank, not an actual place
incomeMean(:,1,:,:) = [];
incomeSD(:,1,:,:) = [];
incomeShare(:,1,:,:) = [];
incomeCounts(:,1,:,:) = [];
peopleCounts(:,1,:,:) = [];
sizeMean(:,1,:,:) = [];
aveNumSources(:,1,:,:) = [];
bUnion(1) = [];

[~,indexInLocations] = ismember(locations.source_ADMIN_NAME, bUnion);

%reorder the matrices so that the order of locations in the HIES data
%matches the order in the spatial data
incomeMean = incomeMean(:,indexInLocations,:,:);
incomeSD = incomeSD(:,indexInLocations,:,:);
incomeShare = incomeShare(:,indexInLocations,:,:);
incomeCounts = incomeCounts(:,indexInLocations,:,:);
peopleCounts = peopleCounts(:,indexInLocations,:,:);
sizeMean = sizeMean(:,indexInLocations,:,:);
aveNumSources = aveNumSources(:,indexInLocations,:,:);
% 
% %%%%%%
% dataYears = [2005 2010 2015];
% for indexI = 1:3
%     figure;   
%     subplot(4,1,1);
%     imagesc(incomeMean(:,:,1,indexI));
%     colorbar;
%     set(gca,'YTick',1:19,'YTickLabel',incomeSources);
%     a = get(gca,'Position');
%     a(3:4) = [0.75 0.15];
%     set(gca,'Position',a);
%     subplot(4,1,2);
%     imagesc(incomeMean(:,:,2,indexI));
%     colorbar;
%     set(gca,'YTick',1:19,'YTickLabel',incomeSources);
%     a = get(gca,'Position');
%     a(3:4) = [0.75 0.15];
%     set(gca,'Position',a);
%     subplot(4,1,3);
%     imagesc(incomeMean(:,:,3,indexI));
%     colorbar;
%     set(gca,'YTick',1:19,'YTickLabel',incomeSources);
%     a = get(gca,'Position');
%     a(3:4) = [0.75 0.15];
%     set(gca,'Position',a);
%     subplot(4,1,4);
%     imagesc(incomeMean(:,:,4,indexI));
%     
%     set(gca,'YTick',1:19,'YTickLabel',incomeSources);
%     set(gca,'XTick',1:64,'XTickLabel',locations.source_ADMIN_NAME);
%     xtickangle(90);
%     colorbar;
%     a = get(gca,'Position');
%     a(3:4) = [0.75 0.15];
%     set(gca,'Position',a);
%     suptitle(num2str(dataYears(indexI)));
% end
% 
% %%%%

%incomeMean has dimensions of (layers - 19 in total, places - 64 divisions, quartiles - 4, time periods - [2005, 2010, and 2015])

% Income layers from incomeMats are as follows:
%     'remittanceincome'  ? calibration parameter
%     'transferincome' ? with remittances
%     'restofotherincome' ? rental income, equal along year, place-specific
%     'annualwageincome' ? split equally along year
%     'annualinkindincome' ? this goes with remittances in calibration
%     'annualsalaryincome' ? split equally along year
%     'incomeothercrops' ? split equally along year
%     'sugarcaneincome' ?time commitment Q1,2,3,4; income in Q1
%     'juteincome' ... time in Q2,3; income in Q3
%     'wheatincome' time in Q4,1; income in Q1
%     'boroRiceincome' time in Q1,2; income in Q2
%     'amanRiceincome' time in Q3,4; income in Q4
%     'ausRiceincome' time in Q2,3; income in Q3
%     'oilseedincome' equal along year
%     'pulseincome' time in Q4,1; income in Q1
%     'maizeincome' time in Q4,1,2; income in Q2
%     'totallivestocksales' equal along year, but possibly exclude
%     'totallfishsales' equal along year, but possibly exclude
%     'totaltreessales' equal along year, but possibly exclude
% (based on
% http://en.banglapedia.org/index.php?title=Agricultural_Calendar)

excludeLayers = [1 2 5 17:19];
incomeMean(excludeLayers,:,:,:) = [];
incomeCounts(excludeLayers,:,:,:) = [];
peopleCounts(excludeLayers,:,:,:) = [];

localOnly = [1; ... %rental income
    0; ... %wage
    0; ... %salary
    1; ... %othercrops
    1; ... %sugarcane
    1; ... %jute
    1; ... %wheat
    1; ... %boro
    1; ... %aman
    1; ... %aus
    1; ... %oilseed
    1; ... %pulse
    1];% ...% ... %maize
    %1; ... %livestock
    %1];% ... %fish
    %1]; %tree

timeQs = [1 1 1 1; ... %rental income
    1 1 1 1; ... %wage
    1 1 1 1; ... %salary
    1 1 1 1; ... %othercrops
    1 1 1 1; ... %sugarcane
    1 1 0 0; ... %jute
    1 0 0 1; ... %wheat
    1 1 0 0; ... %boro
    0 0 1 1; ... %aman
    0 1 1 0; ... %aus
    1 1 1 1; ... %oilseed
    1 0 0 1; ... %pulse
    1 1 0 1];% ... %maize
    %1 1 1 1; ... %livestock
    %1 1 1 1];% ... %fish
    %1 1 1 1]; %tree

incomeQs =[1 1 1 1; ... %rental income
    1 1 1 1; ... %wage
    1 1 1 1; ... %salary
    1 1 1 1; ... %othercrops
    1 0 0 0; ... %sugarcane
    0 0 1 0; ... %jute
    1 0 0 0; ... %wheat
    0 1 0 0; ... %boro
    0 0 0 1; ... %aman
    0 0 1 0; ... %aus
    1 1 1 1; ... %oilseed
    1 0 0 0; ... %pulse
    0 1 0 0];% ... %maize
    %1 1 1 1; ... %livestock
    %1 1 1 1];% ... %fish
    %1 1 1 1]; %tree
   
quarterShare = incomeQs ./ (sum(incomeQs,2));




timeSteps = years * modelParameters.cycleLength;  %2005 to 2015 inclusive

utilityLayerFunctions = [];
for indexI = 1:(size(incomeMean,1)*quantiles)  %16 (or 13) different sources, with 4 levels
    utilityLayerFunctions{indexI,1} = @(k,m,nExpected,n_actual, base) base * (m * nExpected) / (max(0, n_actual - m * nExpected) * k + m * nExpected);   %some income layer - base layer input times density-dependent extinction
end


utilityHistory = zeros(length(locations),length(utilityLayerFunctions),timeSteps+leadTime);
utilityBaseLayers = -9999 * ones(length(locations),length(utilityLayerFunctions),timeSteps);


%estimate expected number of agents for each layer, for use in the utility
%layer function input
locationProb = demographicVariables.locationLikelihood;
locationProb(2:end) = locationProb(2:end) - locationProb(1:end-1);
numAgentsModel = locationProb * modelParameters.numAgents;

nExpected = zeros(length(locations),length(utilityLayerFunctions));
hardSlotCountYN = false(size(nExpected));
for indexI = 1:size(incomeCounts,1) %income layer loop
    for indexJ = 1:size(incomeCounts,2) %location loop
        [~,yearPick1] = max(incomeMean(indexI,indexJ, 1,:));
        [~,yearPick2] = max(incomeMean(indexI,indexJ, 2,:));
        [~,yearPick3] = max(incomeMean(indexI,indexJ, 3,:));
        [~,yearPick4] = max(incomeMean(indexI,indexJ, 4,:));
        nExpected(indexJ,(indexI - 1)*4 + 1) = numAgentsModel(indexJ) * incomeCounts(indexI, indexJ, 1, yearPick1) / peopleCounts(indexI, indexJ, 1, yearPick1);
        nExpected(indexJ,(indexI - 1)*4 + 2) = numAgentsModel(indexJ) * incomeCounts(indexI, indexJ, 2, yearPick2) / peopleCounts(indexI, indexJ, 2, yearPick2);
        nExpected(indexJ,(indexI - 1)*4 + 3) = numAgentsModel(indexJ) * incomeCounts(indexI, indexJ, 3, yearPick3) / peopleCounts(indexI, indexJ, 3, yearPick3);
        nExpected(indexJ,(indexI - 1)*4 + 4) = numAgentsModel(indexJ) * incomeCounts(indexI, indexJ, 4, yearPick4) / peopleCounts(indexI, indexJ, 4, yearPick4);
    end
end
%nExpected(isnan(nExpected)) = 0;
%nExpected(isinf(nExpected)) = 0;

%identify which layers have a strict number of openings, and which layers
%do not (but whose average value may decline with crowding)
hardSlotCountYN(:,1:4) = true; %rental income
hardSlotCountYN(:,5:8) = true; %wage
hardSlotCountYN(:,9:12) = true; %salary
hardSlotCountYN(:,13:16) = false; %othercrops
hardSlotCountYN(:,17:20) = false; %sugarcane
hardSlotCountYN(:,21:24) = false; %jute
hardSlotCountYN(:,25:28) = false; %wheat
hardSlotCountYN(:,29:32) = false; %boro
hardSlotCountYN(:,33:36) = false; %aman
hardSlotCountYN(:,37:40) = false; %aus
hardSlotCountYN(:,41:44) = false; %oilseed
hardSlotCountYN(:,45:48) = false; %pulse
hardSlotCountYN(:,49:52) = false; % ... %maize
%hardSlotCountYN(:,53:56) = false; % ... %fish

%utility layers may be income, use value, etc.  identify what form of
%utility it is, so that they get added and weighted appropriately in
%calculation.  BY DEFAULT, '1' is income.  THE NUMBER IN UTILITY FORMS
%CORRESPONDS WITH THE ELEMENT IN THE AGENT'S B LIST.
utilityForms = zeros(length(utilityLayerFunctions),1);
incomeForms = utilityForms;

%Utility form values correspond to the list of utility coefficients in
%agent utility functions (i.e., numbered 1 to n) ... in this case, all are
%income (same coefficient)
utilityForms(1:length(utilityLayerFunctions)) = 1;

%Income form is either 0 or 1 (with 1 meaning income)
incomeForms = utilityForms == 1;

%estimate the average # of layers occupied by people at different quantiles
aveNumSources(isnan(aveNumSources)) = 0;
diversificationLevel = mean(aveNumSources(1,:,:,:));
diversificationLevel = ceil(reshape(mean(diversificationLevel,4), quantiles,1));

%thus estimate what the average time constraint per layer must be, overall
timeConstraint = (1 - noise) ./ diversificationLevel; %average time commitment per period at each quantile level

%since we have pre-requisites linking layers for Q1-4, we need to estimate
%in each new layer, how much the AGGREGATE time constraint changes (e.g.,
%so that Q1 for layer N can take 90% of time, but Q1+Q2 can jointly take
%70% ... as though they've mechanized, or bought machines, etc.
utilityTimeConstraints = zeros(size(utilityLayerFunctions,1),quantiles);
for indexI = 1:size(timeQs,1)
    for indexJ = 1:length(timeConstraint)
        %time constraint for Q(i) should be such that those for 1 through i
        %add to the value in timeConstraint
        temp = timeConstraint(indexJ) * timeQs(indexI,:);
        temp = temp - sum(utilityTimeConstraints(((indexI - 1)*quantiles + 1):((indexI - 1)*quantiles + (indexJ-1)),:),1);
        utilityTimeConstraints((indexI - 1)*quantiles + indexJ,:) = temp;
    end
end

%define linkages between layers (such as where different layers represent
%progressive investment in a particular line of utility (e.g., farmland)
utilityPrereqs = zeros(size(utilityTimeConstraints,1));
%let the 2nd Quartile require the 1st, the 3rd require 2nd and 1st, and 4th
%require 1st, 2nd, and 3rd for every layer source
for indexI = 4:4:size(utilityTimeConstraints,1)
   utilityPrereqs(indexI, indexI-3:indexI-1) = 1; 
   utilityPrereqs(indexI-1, indexI-3:indexI-2) = 1; 
   utilityPrereqs(indexI-2, indexI-3) = 1; 
end
utilityPrereqs = utilityPrereqs + eye(size(utilityTimeConstraints,1));
utilityPrereqs = sparse(utilityPrereqs);

%with these linkages in place, need to account for the fact that in the
%model, any agent occupying Q4 of something will automatically occupy Q1,
%Q2, Q3, but at present the values nExpected don't account for this.  Thus,
%nExpected for Q1 needs to add in Q2-4, for Q2 needs to add in Q3-4, etc.
%More generally, all 'expected' values need to be adjusted up to allow for
%all things that rely on them.  This is because of a difference between how
%the model interprets layers (occupying Q4 means occupying Q4 + all
%pre-requisites) and the input data (occupying Q4 means only occupying Q4)
tempExpected = zeros(size(nExpected));
for indexI = 1:size(nExpected,2)
   tempExpected(:,indexI) = sum(nExpected(:,utilityPrereqs(:,indexI) > 0),2); 
end
nExpected = tempExpected;

%generate base layers for input; these will be ordered N1Q1 N1Q2 N1Q3 N1Q4
%N2Q1 N2Q2 N2Q3 N2Q4, etc.  (i.e., all layers for one source in order, then
%the next source, etc.)
for indexI = 1:length(locations)
    for indexJ = 1:length(utilityLayerFunctions)
        for indexK = 1:quantiles
            tempMean = zeros(3,1);
            tempMean(:) = incomeMean(ceil(indexJ/quantiles),indexI, indexK,:);
            tempMean(isnan(tempMean)) = 0;  %assume missing data to mean 0 income
            
            %expand from 3 periods to 11 years
            tempMean = interp(tempMean,5,1,0.5);
            tempMean = tempMean(1:11);
            
            %expand from 11 years to 44 quarters
            fullMean = zeros(length(tempMean) * quantiles,1);
            for indexM = 1:length(tempMean)
                fullMean((indexM-1)*quantiles+1:indexM*quantiles) = tempMean(indexM) * quarterShare(ceil(indexJ/quantiles),:);
            end
            
            utilityBaseLayers(indexI,indexJ,:) = fullMean;
            
            
        end
    end
end

%now add some lead time for agents to learn before time actually starts
%moving
utilityBaseLayers(:,:,leadTime+1:leadTime+timeSteps) = utilityBaseLayers;
for indexI = leadTime:-1:1
   utilityBaseLayers(:,:,indexI) = utilityBaseLayers(:,:,indexI+modelParameters.cycleLength); 
end

%estimate costs for access, such that the expected ROI is i +/- noise, given discount
%rate j, assuming average value over time from incomeMean and estimating
%marginal increase moving from one quartile to the next.  for assets, these
%values are place-specific.  for qualifications, average the costs over the
%appropriate domain
accessCodeCount = 1;
numCodes = sum(localOnly) * quantiles * size(locations,1) + sum(~localOnly) * quantiles;

utilityAccessCodesMat = false(length(locations),length(utilityLayerFunctions),numCodes);
utilityAccessCosts = [];
for indexI = 1:length(localOnly)
   if(localOnly(indexI))
        meanValues = mean(utilityBaseLayers(:,(indexI-1)*quantiles+1:indexI*quantiles,:,:),3);
        accessCost = meanValues / (1 + iReturn) * ((1+iDiscount)^iYears -1) / iDiscount / ((1 + iDiscount)^iYears);  %using CCRF to estimate access cost
        for indexJ = 1:quantiles
           utilityAccessCosts = [utilityAccessCosts; [(accessCodeCount:accessCodeCount + length(locations)-1)' accessCost(:,indexJ)]];   
           for indexK = 1:length(locations)
               utilityAccessCodesMat(indexK,(indexI-1)*quantiles+indexJ, accessCodeCount) = 1;
               accessCodeCount = accessCodeCount + 1;
           end
        end       
   else
        meanValues = mean(mean(utilityBaseLayers(:,(indexI-1)*quantiles+1:indexI*quantiles,:,:),3),1);
        accessCost = meanValues / (1 + iReturn) * ((1+iDiscount)^iYears -1) / iDiscount / ((1 + iDiscount)^iYears);
        for indexJ = 1:quantiles
           utilityAccessCosts = [utilityAccessCosts; [(accessCodeCount+1) accessCost(indexJ)]];   
           utilityAccessCodesMat(:,(indexI-1)*quantiles+indexJ, accessCodeCount) = 1;
           accessCodeCount = accessCodeCount + 1;
        end
   end
end


%any hack code for testing ideas can go below here but should be commented
%when not in use...
% utilityAccessCosts(1:quantiles * size(locations,1),2) = 0.2 * utilityAccessCosts(1:quantiles * size(locations,1),2);
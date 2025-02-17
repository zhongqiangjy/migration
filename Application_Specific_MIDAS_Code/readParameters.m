function [agentParameters, modelParameters, networkParameters, mapParameters] = readParameters(inputs)

%All model parameters go here
modelParameters.spinupTime = 10;
modelParameters.numAgents = 200;
mapParameters.sizeX = 600;
mapParameters.sizeY = 600;
modelParameters.cycleLength = 4;
modelParameters.incomeInterval = 1;
modelParameters.visualizeYN = 0;
modelParameters.listTimeStepYN = 0;
modelParameters.visualizeInterval = 1;
modelParameters.showMovesOrNetwork = 0; %1 for recent moves, 0 for network
modelParameters.movesFadeSteps = 12; 
modelParameters.edgeAlpha = 0.2; 
modelParameters.ageDecision = 15;
modelParameters.ageLearn = 10;
modelParameters.utility_k = 4;
modelParameters.utility_m = 1;
modelParameters.utility_noise = 0.05;
modelParameters.utility_iReturn = 0.05;
modelParameters.utility_iDiscount = 0.05;
modelParameters.utility_iYears = 20;
modelParameters.remitRate = 0;
modelParameters.creditMultiplier = 0.3;
mapParameters.movingCostPerMile = 0;
mapParameters.minDistForCost = 50;
mapParameters.maxDistForCost = 400;
networkParameters.networkDistanceSD = 7;
networkParameters.connectionsMean = 2;
networkParameters.connectionsSD = 2;
networkParameters.agentPreAllocation = modelParameters.numAgents * 3;
networkParameters.nonZeroPreAllocation = networkParameters.agentPreAllocation * 10;
networkParameters.weightLocation = 3;
networkParameters.weightNetworkLink = 5;
networkParameters.weightSameLayer = 3;
networkParameters.distancePolynomial = 0.0002;
networkParameters.decayPerStep = 0.002;
networkParameters.interactBump = 0.01;
networkParameters.shareBump = 0.001;
mapParameters.degToRad = 0.0174533;
mapParameters.milesPerDeg = 69; %use for estimating actual distances in distance Matrix
mapParameters.density = 60; %pixels per degree Lat/Long, if using .shp input
mapParameters.colorSpacing = 20;
mapParameters.numDivisionMean = [2 8 9];
mapParameters.numDivisionSD = [0 2 1];
mapParameters.position = [300 100 600 600];
mapParameters.r1 = []; %this will be the spatial reference if we are pulling from a shape file
mapParameters.filePath = './Data/Bangladesh Data/ipums_district_level.shp';
mapParameters.saveDirectory = './Outputs/';
modelParameters.popFile = './Data/Bangladesh Data/ban_pop_estimate_ipums.xls';
modelParameters.survivalFile = './Data/Bangladesh Data/mortality_ban.xls';
modelParameters.fertilityFile = './Data/Bangladesh Data/fert_age_ban.xls';
modelParameters.agePreferencesFile = './Data/Bangladesh Data/age_specific_params.xls';
modelParameters.utilityDataPath = './Data/Bangladesh Data';
modelParameters.saveImg = false;
modelParameters.shortName = 'Bangladesh_test';
agentParameters.currentID = 1;
agentParameters.incomeShareFractionMean = 0.4;
agentParameters.incomeShareFractionSD = 0;
agentParameters.shareCostThresholdMean = 0.3;
agentParameters.shareCostThresholdSD = 0;
agentParameters.wealthMean = 0;
agentParameters.wealthSD = 0;
agentParameters.interactMean = 0.8;
agentParameters.interactSD = 0;
agentParameters.meetNewMean = 0.1;
agentParameters.meetNewSD = 0;
agentParameters.probAddFitElementMean = 0.4;
agentParameters.probAddFitElementSD = 0;
agentParameters.randomLearnMean = 1;
agentParameters.randomLearnSD = 0;
agentParameters.randomLearnCountMean = 5;
agentParameters.randomLearnCountSD = 0;
agentParameters.chooseMean = 0.4;
agentParameters.chooseSD = 0;
agentParameters.knowledgeShareFracMean = 0.3;
agentParameters.knowledgeShareFracSD = 0;
agentParameters.bestLocationMean = 2;
agentParameters.bestLocationSD = 0;
agentParameters.bestPortfolioMean = 2;
agentParameters.bestPortfolioSD = 0;
agentParameters.randomLocationMean = 2;
agentParameters.randomLocationSD = 0;
agentParameters.randomPortfolioMean = 2;
agentParameters.randomPortfolioSD = 0;
agentParameters.numPeriodsEvaluateMean = 6;
agentParameters.numPeriodsEvaluateSD = 0;
agentParameters.numPeriodsMemoryMean = 18;
agentParameters.numPeriodsMemorySD = 0;
agentParameters.discountRateMean = 0.04;
agentParameters.discountRateSD = 0;
agentParameters.rValueMean = 0.85;
agentParameters.rValueSD = 0.2;
agentParameters.bListMean = 0.5;
agentParameters.bListSD = 0.2;
agentParameters.prospectLossMean = 2;
agentParameters.prospectLossSD = 0;
agentParameters.informedExpectedProbJoinLayerMean = 1;
agentParameters.informedExpectedProbJoinLayerSD = 0;
agentParameters.uninformedMaxExpectedProbJoinLayerMean = 0.4;
agentParameters.uninformedMaxExpectedProbJoinLayerSD = 0;
agentParameters.expectationDecayMean = 0.1;
agentParameters.expectationDecaySD = 0;

%override any input variables. 'inputs' should be a dataset with two columns,
%one with the parameter name and one with the value
if(~isempty(inputs))
   for indexI = 1:size(inputs,1)
       eval([inputs.parameterNames{indexI} ' = ' num2str(inputs.parameterValues(indexI)) ';']);
   end
end

modelParameters.timeSteps = modelParameters.spinupTime + 44;  %in this particular experiment only, there are 44 time steps with data


end


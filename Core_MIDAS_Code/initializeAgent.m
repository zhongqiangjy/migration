function newAgent = initializeAgent(agentParameters, utilityVariables, age, gender, location)

knowledgeShareFrac = min(1,max(0,agentParameters.knowledgeShareFracMean + randn() * agentParameters.knowledgeShareFracSD));
shareCostThreshold = min(1,max(0,agentParameters.shareCostThresholdMean + randn() * agentParameters.shareCostThresholdSD));
incomeShareFraction = min(1,max(0,agentParameters.incomeShareFractionMean + randn() * agentParameters.incomeShareFractionSD));
wealth = max(0,agentParameters.wealthMean + randn() * agentParameters.wealthSD);
numBestLocation = max(1,round(agentParameters.bestLocationMean + randn() * agentParameters.bestLocationSD));
numBestPortfolio = max(1,round(agentParameters.bestPortfolioMean + randn() * agentParameters.bestPortfolioSD));
numRandomLocation = max(1,round(agentParameters.randomLocationMean + randn() * agentParameters.randomLocationSD));
numRandomPortfolio = max(1,round(agentParameters.randomPortfolioMean + randn() * agentParameters.randomPortfolioSD));
numPeriodsEvaluate = max(1,round(agentParameters.numPeriodsEvaluateMean + randn() * agentParameters.numPeriodsEvaluateSD));
numPeriodsMemory = max(1,round(agentParameters.numPeriodsMemoryMean + randn() * agentParameters.numPeriodsMemorySD));
pInteract = min(1,max(0,agentParameters.interactMean + randn() * agentParameters.interactSD));
pMeetNew = min(1,max(0,agentParameters.meetNewMean + randn() * agentParameters.meetNewSD));
pAddFitElement = min(1,max(0,agentParameters.probAddFitElementMean + randn() * agentParameters.probAddFitElementSD));
pRandomLearn = min(1,max(0,agentParameters.randomLearnMean + randn() * agentParameters.randomLearnSD));
countRandomLearn = min(1,max(0,round(agentParameters.randomLearnCountMean + randn() * agentParameters.randomLearnCountSD)));
pChoose = min(1,max(0,agentParameters.chooseMean + randn() * agentParameters.chooseSD));
rValue = max(0,agentParameters.rValueMean + randn() * agentParameters.rValueSD);
discountRate = max(0, agentParameters.discountRateMean + randn() * agentParameters.discountRateSD);
prospectLoss = -max(0, agentParameters.prospectLossMean + randn() * agentParameters.prospectLossSD);
pGetLayer_informed = min(1,max(0,agentParameters.informedExpectedProbJoinLayerMean + randn() * agentParameters.informedExpectedProbJoinLayerSD));
pGetLayer_uninformed = min(1,max(0,agentParameters.uninformedMaxExpectedProbJoinLayerMean + randn() * agentParameters.uninformedMaxExpectedProbJoinLayerSD));
fDecay = min(1,max(0,agentParameters.expectationDecayMean + randn() * agentParameters.expectationDecaySD));


%bList has elements corresponding to each kind of utility layer present
bList = max(0, agentParameters.bListMean + randn(utilityVariables.numForms,1) * agentParameters.bListSD);

newAgent = Agent(agentParameters.currentID, location);

newAgent.accessCodesPaid = agentParameters.init_accessCodesPaid;
newAgent.knowsIncomeLocation = agentParameters.init_knowsIncomeLocation;
newAgent.incomeLayersHistory = agentParameters.init_incomeLayersHistory;
newAgent.expectedProbOpening = agentParameters.init_expectedProbOpening;
newAgent.heardOpening = agentParameters.init_knowsIncomeLocation;
newAgent.personalIncomeHistory = zeros(size(agentParameters.init_incomeLayersHistory,3),1);
newAgent.timeProbOpeningUpdated = zeros(size(agentParameters.init_expectedProbOpening));
newAgent.currentSharedIn = 0;

newAgent.knowledgeShareFrac = knowledgeShareFrac;
newAgent.shareCostThreshold = shareCostThreshold;
newAgent.incomeShareFraction = incomeShareFraction;
newAgent.wealth = wealth;
newAgent.realizedUtility = 0;
newAgent.numBestLocation = numBestLocation;
newAgent.numBestPortfolio = numBestPortfolio;
newAgent.numRandomLocation = numRandomLocation;
newAgent.numRandomPortfolio = numRandomPortfolio;
newAgent.bestPortfolios = cell(size(utilityVariables.utilityHistory,1),numBestPortfolio);
newAgent.bestPortfolioValues = zeros(size(utilityVariables.utilityHistory,1),numBestPortfolio);
newAgent.pInteract = pInteract;
newAgent.pMeetNew = pMeetNew;
newAgent.pAddFitElement = pAddFitElement;
newAgent.pRandomLearn = pRandomLearn;
newAgent.countRandomLearn = countRandomLearn;
newAgent.pChoose = pChoose;
newAgent.fDecay = fDecay;
newAgent.pGetLayer_informed = pGetLayer_informed;
newAgent.pGetLayer_uninformed = pGetLayer_uninformed;
newAgent.numPeriodsEvaluate = numPeriodsEvaluate;
newAgent.numPeriodsMemory = numPeriodsMemory;
newAgent.discountRate = discountRate;
newAgent.rValue = rValue;
newAgent.bList = bList;
newAgent.prospectLoss = prospectLoss;
newAgent.age = age;
newAgent.gender = gender;

end
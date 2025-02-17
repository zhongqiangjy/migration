function [bestCalibrationSet, fitnessHistory, population] = newPopulation(gAParameters)

%some fitness function data - 
%use just 2002 data for now
%migrationData = reshape(interDistrictMovesMat(:,:,1),64,64);
%popData = reshape(popMat(:,1),64,1);

load migrationCounts_2002_2011;
load midasLocations;

%average data from 2002 to 2011
popData = mean(popMat,2);
interDistrictMovesMat(isnan(interDistrictMovesMat)) = 0;
migrationData = mean(interDistrictMovesMat,3);

sourcePopWeights = popData * ones(1, 64);
destPopWeights = sourcePopWeights';
jointPopWeights = sourcePopWeights .* destPopWeights;

%sourcePopSum = sum(sum(sourcePopWeights));
%destPopSum = sum(sum(destPopWeights));
jointPopSum = sum(sum(jointPopWeights));


%one simple metric is the relative # of migrations per source-destination
%pair
fracMigsData = migrationData / sum(sum(migrationData));

%another is the migs per total population
migRateData = migrationData / sum(popData);

%and another is the in/out ratio
inOutData = sum(migrationData) ./ (sum(migrationData'));
inOutData(isnan(inOutData)) = 0;
inOutData(isinf(inOutData)) = 0;

fitnessData.fracMigsData = fracMigsData;
fitnessData.migRateData = migRateData;
fitnessData.inOutData = inOutData;
fitnessData.jointPopWeights = jointPopWeights;
fitnessData.jointPopSum = jointPopSum;
fitnessData.popData = popData;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%define the levels and parameters you will explore, as below
mcParams = table([],[],[],[],'VariableNames',{'Name','Lower','Upper','RoundYN'});
mcParams = [mcParams; {'modelParameters.spinupTime', 8, 20, 1}];
mcParams = [mcParams; {'modelParameters.numAgents', 3000, 6000, 1}];
mcParams = [mcParams; {'modelParameters.utility_k', 1, 5, 0}];
mcParams = [mcParams; {'modelParameters.utility_m', 1, 2, 0}];
mcParams = [mcParams; {'modelParameters.utility_noise', 0, 0.1, 0}];
mcParams = [mcParams; {'modelParameters.utility_iReturn', 0, 0.2, 0}];
mcParams = [mcParams; {'modelParameters.utility_iDiscount', 0, 0.1, 0}];
mcParams = [mcParams; {'modelParameters.utility_iYears', 10, 20, 1}];
mcParams = [mcParams; {'modelParameters.remitRate', 0, 20, 0}];
mcParams = [mcParams; {'mapParameters.movingCostPerMile', 0, 5000, 0}];
mcParams = [mcParams; {'mapParameters.minDistForCost', 0, 50, 0}];
mcParams = [mcParams; {'mapParameters.maxDistForCost', 0, 5000, 0}];
mcParams = [mcParams; {'networkParameters.networkDistanceSD', 5, 15, 1}];
mcParams = [mcParams; {'networkParameters.connectionsMean', 1, 5, 1}];
mcParams = [mcParams; {'networkParameters.connectionsSD', 1, 3, 1}];
mcParams = [mcParams; {'networkParameters.weightLocation', 5, 15, 0}];
mcParams = [mcParams; {'networkParameters.weightNetworkLink', 5, 15, 0}];
mcParams = [mcParams; {'networkParameters.weightSameLayer', 3, 10, 0}];
mcParams = [mcParams; {'networkParameters.distancePolynomial', 0.0001, 0.0003, 0}];
mcParams = [mcParams; {'networkParameters.decayPerStep', 0.001, 0.01, 0}];
mcParams = [mcParams; {'networkParameters.interactBump', 0.005, 0.03, 0}];
mcParams = [mcParams; {'networkParameters.shareBump', 0.0005, 0.005, 0}];
mcParams = [mcParams; {'agentParameters.incomeShareFractionMean', 0.2, 0.6, 0}];
mcParams = [mcParams; {'agentParameters.incomeShareFractionSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.shareCostThresholdMean', 0.2, 0.6, 0}];
mcParams = [mcParams; {'agentParameters.shareCostThresholdSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.interactMean', 0.2, 0.6, 0}];
mcParams = [mcParams; {'agentParameters.interactSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.meetNewMean', 0.2, 0.6, 0}];
mcParams = [mcParams; {'agentParameters.meetNewSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.probAddFitElementMean', 0.2, 0.6, 0}];
mcParams = [mcParams; {'agentParameters.probAddFitElementSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.randomLearnMean', 0.2, 0.6, 0}];
mcParams = [mcParams; {'agentParameters.randomLearnSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.randomLearnCountMean', 1, 3, 1}];
mcParams = [mcParams; {'agentParameters.randomLearnCountSD', 0, 2, 1}];
mcParams = [mcParams; {'agentParameters.chooseMean', 0.4, 0.8, 0}];
mcParams = [mcParams; {'agentParameters.chooseSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.knowledgeShareFracMean', 0.05, 0.4, 0}];
mcParams = [mcParams; {'agentParameters.knowledgeShareFracSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.bestLocationMean', 1, 3, 1}];
mcParams = [mcParams; {'agentParameters.bestLocationSD', 0, 2, 1}];
mcParams = [mcParams; {'agentParameters.bestPortfolioMean', 1, 3, 1}];
mcParams = [mcParams; {'agentParameters.bestPortfolioSD', 0, 2, 1}];
mcParams = [mcParams; {'agentParameters.randomLocationMean', 1, 3, 1}];
mcParams = [mcParams; {'agentParameters.randomLocationSD', 0, 2, 1}];
mcParams = [mcParams; {'agentParameters.randomPortfolioMean', 1, 3, 1}];
mcParams = [mcParams; {'agentParameters.randomPortfolioSD', 0, 2, 1}];
mcParams = [mcParams; {'agentParameters.numPeriodsEvaluateMean', 6, 24, 1}];
mcParams = [mcParams; {'agentParameters.numPeriodsEvaluateSD', 0, 6, 1}];
mcParams = [mcParams; {'agentParameters.numPeriodsMemoryMean', 6, 24, 1}];
mcParams = [mcParams; {'agentParameters.numPeriodsMemorySD', 0, 6, 1}];
mcParams = [mcParams; {'agentParameters.discountRateMean', 0.02, 0.1, 0}];
mcParams = [mcParams; {'agentParameters.discountRateSD', 0, 0.02, 0}];
mcParams = [mcParams; {'agentParameters.rValueMean', 0.75, 1.5, 0}];
mcParams = [mcParams; {'agentParameters.rValueSD', 0.1, 0.4 , 0}];
mcParams = [mcParams; {'agentParameters.bListMean', 0.5, 1, 0}];
mcParams = [mcParams; {'agentParameters.bListSD', 0, 0.4, 0}];
mcParams = [mcParams; {'agentParameters.prospectLossMean', 1, 2, 0}];
mcParams = [mcParams; {'agentParameters.prospectLossSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.informedExpectedProbJoinLayerMean', 0.8, 1,0}];
mcParams = [mcParams; {'agentParameters.informedExpectedProbJoinLayerSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.uninformedMaxExpectedProbJoinLayerMean', 0, 0.4, 0}];
mcParams = [mcParams; {'agentParameters.uninformedMaxExpectedProbJoinLayerSD', 0, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.expectationDecayMean', 0.05, 0.2, 0}];
mcParams = [mcParams; {'agentParameters.expectationDecaySD', 0, 0.2, 0}];

%population is a cell array of portfolio cells
temp = dir('latestPopulation.mat');
if(isempty(temp))
    population = {};
    startStep = 1;
    fitnessScore = zeros(gAParameters.sizeGeneration,1);
    rawFitnessScore = zeros(gAParameters.sizeGeneration,3);
    weightedR2 = fitnessScore;
    fitnessHistory = zeros(gAParameters.generations,1);
    r2History = zeros(gAParameters.generations,1);
else
    load('latestPopulation.mat'); 
    startStep = find(fitnessHistory == 0);
    startStep = startStep(1);
    fitnessScore = zeros(gAParameters.sizeGeneration,1);
    rawFitnessScore = zeros(gAParameters.sizeGeneration,3);
end

%if prior generation is empty, build first generation with randomly
%generated portfolios from the buildPortfolio function
if(isempty(population))
    population = cell(gAParameters.sizeGeneration,1);
    parfor indexI = 1:gAParameters.sizeGeneration
        population{indexI} = drawRandomCalibrationSet(mcParams);
    end
end


%evaluate the set of scores of this initial population and initialize a
%history vector for the best fitness score over time

%in this particular application, fitness = SSE, and is to be minimized
%(note that in many applications, fitness may be defined in such a way that
%it is to be minimized)


parfor indexJ = 1:gAParameters.sizeGeneration

    %evaluate fitness as utility using estRemainingUtility function; all
    %choices in population are evaluated from their time 0
    output = midasMainLoop(population{indexJ}, ['Run ' num2str(indexJ)]);
    
    %calculate the SSE
    %fracMigsRun = output.migrationMatrix / sum(sum(output.migrationMatrix));
   % migRateRun = output.migrationMatrix / size(output.agentSummary,1) / 11;  %(this data is 11 years)

    %SSE = sum(sum(((migRateRun - migRateData).^2).*jointPopWeights))/jointPopSum;
    %r2 = weightedPearson(migRateRun(:), migRateData(:), jointPopWeights(:));

    rawFitnessScore(indexJ,:) = calcFitness(output, fitnessData);
    
    %fitnessScore(indexJ) = SSE;
    %weightedR2(indexJ) = r2;
    
end
    
rawFitnessScore = rawFitnessScore ./ (ones(size(rawFitnessScore,1),1) * max(rawFitnessScore));
fitnessScore = rawFitnessScore(:,1) * gAParameters.rawFitnessWeights(1) + ...
    rawFitnessScore(:,2) * gAParameters.rawFitnessWeights(2) + ...
    rawFitnessScore(:,3) * gAParameters.rawFitnessWeights(3);

%make a scale from 0 to 1 to capture the appropriate
%probabilities of crossover, mutation, or straight reproduction
reproduceScale = [gAParameters.pCrossover gAParameters.pMutate gAParameters.pReproduce];
reproduceScale = cumsum(reproduceScale)/sum(reproduceScale);
reproduceIndex = 1:3; %1) crossover 2) mutate 3) reproduce

    
%run the necessary generations of GP algorithm (evaluate fit, get next
%generation)

for indexI = startStep:gAParameters.generations
    
    
    %initialize an empty array for the next generation
    newPopulation = cell(gAParameters.sizeGeneration,1);
    
    %apply a different procedure for populating, depending on the selection
    %method
    switch gAParameters.selectionMethod
        
        case 1 %probabilistic selection
            
            %make two scales ranging from 0 to 1, for 1) the cumulative
            %fitness score and 2) the cumulative probabilities of different
            %reproduction methods
            
            %first, make a scale from 0 to 1, such that portfolios with
            %highest utility occupy the greatest ranges along this scale,
            %and those with lowest occupy the least.  in this particular
            %case, we rescale fitness score so that the lowest utilities
            %are 0, and will occupy 0 space along this scale
            if(gAParameters.isBestFitnessMin == 1)
                fitnessScore = max(fitnessScore) - fitnessScore;  %thus, lowest score will have 0 probability
            else
                fitnessScore = fitnessScore - min(fitnessScore);  %thus, lowest score will have 0 probability
            end
            fitnessScore(isnan(fitnessScore)) = 0;
            if(sum(fitnessScore ~= 0) == 0)
               %all zero, perhaps because all options had negative utility
               fitnessScore(:) = 1;
            end
            fitnessScale = cumsum(fitnessScore)/sum(fitnessScore);
                        
            %make an index for each portfolio in the parent generation
            fitnessIndex = 1:gAParameters.sizeGeneration;
            
            %while the new generation is not yet full, keep adding to it
            indexJ = 1;
            while indexJ <= gAParameters.sizeGeneration
                
                %randomly select a reproduction method according to their
                %likelihood - crossover(1), mutation(2), or reproduction(3)
                reproduceMethod = rand() < reproduceScale;
                reproduceMethod = reproduceIndex(reproduceMethod);
                switch reproduceMethod(1)
                    
                    case 1  % crossover
                        
                        %randomly choose two parents, using the
                        %fitnessIndex so that higher utilities are more
                        %likely to be selected
                        parent1Search = rand() < fitnessScale;
                        parent1Search = fitnessIndex(parent1Search);
                        parent1 = population{parent1Search(1)};
                        parent2Search = rand() < fitnessScale;
                        parent2Search = fitnessIndex(parent2Search);
                        parent2 = population{parent2Search(1)};
                        %crossover to create children using the
                        %crossoverPortfolio function
                        [child1, child2] = crossoverPortfolio(parent1, parent2);

                        %add children to next generation; only add second
                        %child if there is room
                        newPopulation{indexJ} = child1;
                        indexJ = indexJ + 1;
                        if(indexJ < gAParameters.sizeGeneration)
                            newPopulation{indexJ} = child2;
                            indexJ = indexJ + 1;
                        end
                        
                    case 2  % mutate
                        
                        %randomly choose one parent, using the
                        %fitnessIndex so that higher utilities are more
                        %likely to be selected
                        parentSearch = rand() < fitnessScale;
                        parentSearch = fitnessIndex(parentSearch);
                        parent = population{parentSearch(1)};
                        
                        %mutate to create child using the mutatePortfolio
                        %function
                        child = mutatePortfolio(parent, mcParams);

                        %add child to next generation
                        newPopulation{indexJ} = child;
                        indexJ = indexJ + 1;
                        
                        
                    case 3  % reproduce
                        
                        %randomly choose one parent, using the
                        %fitnessIndex so that higher utilities are more
                        %likely to be selected
                        parentSearch = rand() < fitnessScale;
                        parentSearch = fitnessIndex(parentSearch);
                        
                        %add parent directly to next generation
                        newPopulation{indexJ} = population{parentSearch(1)};
                        indexJ = indexJ + 1;
                        
                end
            end
            
            
        case 2 %tournament selection
                
            %make sure better scores are always larger
            if(gAParameters.isBestFitnessMin == 1)
                fitnessScore = max(fitnessScore) - fitnessScore;  
            else
                fitnessScore = fitnessScore - min(fitnessScore);  
            end
            
            %while the new generation is not yet full, keep adding to it
            indexJ = 1;
            while indexJ <= gAParameters.sizeGeneration
                
                
                %randomly select a reproduction method according to their
                %likelihood - crossover(1), mutation(2), or reproduction(3)
                reproduceMethod = rand() < reproduceScale;
                reproduceMethod = reproduceIndex(reproduceMethod);
                switch reproduceMethod(1)
                    
                    case 1  % crossover
                        
                        %randomly choose two parents, by selecting two small
                        %sets of portfolios and creating 'tournaments' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parent1Search = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parent1Search);
                        parent1 = population{parent1Search(tournamentScore == max(tournamentScore))};
                        
                        parent2Search = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parent2Search);
                        parent2 = population{parent2Search(tournamentScore == max(tournamentScore))};
                        
                        %crossover to create children using the
                        %crossoverPortfolio function
                        [child1, child2] = crossoverPortfolio(parent1, parent2);
                        
                        %add children to next generation; only add second
                        %child if there is room
                        newPopulation{indexJ} = child1;
                        indexJ = indexJ + 1;
                        if(indexJ < gAParameters.sizeGeneration)
                            newPopulation{indexJ} = child2;
                            indexJ = indexJ + 1;
                        end
                        
                    case 2  % mutate
                        
                        %randomly choose one parent, by selecting one small
                        %set of portfolios and creating a 'tournament' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parentSearch = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parentSearch);
                        parent = population{parentSearch(tournamentScore == max(tournamentScore))};
                        
                        %mutate to create child using the mutatePortfolio
                        %function
                        child = mutatePortfolio(parent, mcParams);
                        
                        %add child to next generation
                        newPopulation{indexJ} = child;
                        indexJ = indexJ + 1;
                        
                        
                    case 3  % reproduce
                        
                        %randomly choose one parent, by selecting one small
                        %set of portfolios and creating a 'tournament' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parentSearch = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parentSearch);
                        parent = population{parentSearch(tournamentScore == max(tournamentScore))};
                        
                        %add parent directly to next generation
                        newPopulation{indexJ} = population{parentSearch};
                        indexJ = indexJ + 1;
                        
                end
            end
            
        case 3 %elite tournament selection
            
            %this is the same as tournament selection, except that the best
            %function from the previous generation is automatically
            %included
            
            %make sure better scores are always larger
            if(gAParameters.isBestFitnessMin == 1)
                fitnessScore = max(fitnessScore) - fitnessScore;
            else
                fitnessScore = fitnessScore - min(fitnessScore);
            end
            
            %first, put the previous best function as the first element in
            %the new generation.  in case there are more than one with the
            %same minimum score, pick one randomly
            previousBest = find(fitnessScore == max(fitnessScore));
            previousBest = previousBest(randperm(length(previousBest)));
            previousBest = previousBest(1);

            newPopulation{1} = population{previousBest};
            
            %while the new generation is not yet full, keep adding to it
            indexJ = 2;
            while indexJ <= gAParameters.sizeGeneration
                
                
                %randomly select a reproduction method according to their
                %likelihood - crossover(1), mutation(2), or reproduction(3)
                reproduceMethod = rand() < reproduceScale;
                reproduceMethod = reproduceIndex(reproduceMethod);
                switch reproduceMethod(1)
                    
                    case 1  % crossover
                        
                        %randomly choose two parents, by selecting two small
                        %sets of portfolios and creating 'tournaments' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parent1Search = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parent1Search);
                        parent1 = population{parent1Search(tournamentScore == max(tournamentScore))};
                        
                        parent2Search = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parent2Search);
                        parent2 = population{parent2Search(tournamentScore == max(tournamentScore))};

                        %crossover to create children using the
                        %crossoverPortfolio function
                        [child1, child2] = crossoverPortfolio(parent1, parent2);

                        %add children to next generation; only add second
                        %child if there is room
                        newPopulation{indexJ} = child1;
                        indexJ = indexJ + 1;
                        if(indexJ < gAParameters.sizeGeneration)
                            newPopulation{indexJ} = child2;
                            indexJ = indexJ + 1;
                        end
                        
                    case 2  % mutate
                        
                        %randomly choose one parent, by selecting one small
                        %set of portfolios and creating a 'tournament' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parentSearch = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parentSearch);
                        parent = population{parentSearch(tournamentScore == max(tournamentScore))};
                        
                        %mutate to create child using the mutatePortfolio
                        %function
                        child = mutatePortfolio(parent, mcParams);
                        
                        
                        %add child to next generation
                        newPopulation{indexJ} = child;
                        indexJ = indexJ + 1;
                        
                        
                    case 3  % reproduce
                        
                        %randomly choose one parent, by selecting one small
                        %set of portfolios and creating a 'tournament' -
                        %the portfolio in a tournament with the highest
                        %fitness becomes one parent
                        parentSearch = ceil(rand(gAParameters.tournamentSize,1) * gAParameters.sizeGeneration);
                        tournamentScore = fitnessScore(parentSearch);
                        parent = population{parentSearch(tournamentScore == max(tournamentScore))};
                        
                        %add parent directly to next generation
                        newPopulation{indexJ} = parent;
                        indexJ = indexJ + 1;
                        
                end
            end
            
    end
    
    %HACK
    %make sure we keep the best one from the last round
    %note that at this point, all 3 approaches have made the largest
    %fitness score the best, no matter how it was originally defined
    replaceMember = randperm(length(newPopulation),1);
    bestPrevious = find(fitnessScore == max(fitnessScore));
    newPopulation(replaceMember) = population(bestPrevious(1));
    
    %set the current population to be this new population
   
    population = newPopulation;
    
    
    parfor indexK = 1:gAParameters.sizeGeneration
        
        %evaluate fitness as utility using estRemainingUtility function; all
        %choices in population are evaluated from their time 0
        output = midasMainLoop(population{indexK}, ['Run ' num2str(indexK)]);
        
        %calculate the SSE
        %fracMigsRun = output.migrationMatrix / sum(sum(output.migrationMatrix));
%         migRateRun = output.migrationMatrix / size(output.agentSummary,1) / 11;  %(this data is 11 years)
%         
%         SSE = sum(sum(((migRateRun - migRateData).^2).*jointPopWeights))/jointPopSum;
%         
%         r2 = weightedPearson(migRateRun(:), migRateData(:), jointPopWeights(:));
% 
%         fitnessScore(indexK) = SSE;
%         weightedR2(indexK) = r2;
% 
            rawFitnessScore(indexK,:) = calcFitness(output, fitnessData);
            
    end
    
    rawFitnessScore = rawFitnessScore ./ (ones(size(rawFitnessScore,1),1) * max(rawFitnessScore));
    fitnessScore = rawFitnessScore(:,1) * gAParameters.rawFitnessWeights(1) + ...
        rawFitnessScore(:,2) * gAParameters.rawFitnessWeights(2) + ...
        rawFitnessScore(:,3) * gAParameters.rawFitnessWeights(3);
    
    
    %mark the best (lowest) fitness score in the current population
    if(gAParameters.isBestFitnessMin == 1)
        [fitnessHistory(indexI),indexMin] = min(fitnessScore);
    else
        [fitnessHistory(indexI),indexMin] = max(fitnessScore);
    end
    
    %Check for convergence (measured as the relative change in top fitness score between generations), and if we aren't changing much, quit early
    testConverged = 0;
    if(indexI > gAParameters.changeScoreRounds+1)
        if(mean(abs((fitnessHistory(indexI-gAParameters.changeScoreRounds:indexI)  - min(fitnessHistory(indexI-gAParameters.changeScoreRounds-1:indexI-1)))./min(fitnessHistory(indexI-gAParameters.changeScoreRounds-1:indexI-1)))) < gAParameters.changeScoreTol)
            testConverged = 1;
        end
    end
    if(testConverged)
        break;
    end
    
    fprintf('\n Timestep %d of %d; Min. Score = %f',indexI, gAParameters.generations,fitnessHistory(indexI));
    %select the function with best fit (using in this case a random draw as a
    %tie-breaking rule)
    if(gAParameters.isBestFitnessMin == 1)
        bestChoice = find(fitnessScore(:,1) == min(fitnessScore(:,1)));
    else
        bestChoice = find(fitnessScore(:,1) == max(fitnessScore(:,1)));
    end
    bestChoice = bestChoice(randperm(length(bestChoice),1));
    bestCalibrationSet = population{bestChoice,1};
    
    save latestPopulation population fitnessHistory bestCalibrationSet;
    
end


end %function newPopulation

function fitness = calcFitness(run, data)

fracMigsRun = run.migrationMatrix / sum(sum(run.migrationMatrix));
migRateRun = run.migrationMatrix / size(run.agentSummary,1) / 11;  %(this data is 11 years)
inOutRun = sum(run.migrationMatrix) ./ (sum(run.migrationMatrix'));
inOutRun(isnan(inOutRun)) = 0;
inOutRun(isinf(inOutRun)) = 0;

jointWeightFracMigsError = sum(sum(((fracMigsRun - data.fracMigsData).^2).*data.jointPopWeights))/data.jointPopSum;

jointWeightMigRateError = sum(sum(((migRateRun - data.migRateData).^2).*data.jointPopWeights))/data.jointPopSum;

popWeightInOutError = sum(sum(((inOutRun - data.inOutData).^2).*data.popData))/sum(data.popData);


fitness = [ jointWeightFracMigsError  jointWeightMigRateError  popWeightInOutError];

end

function rho_2 = weightedPearson(X, Y, w)

mX = sum(X .* w) / sum(w);
mY = sum(Y .* w) / sum(w);

covXY = sum (w .* (X - mX) .* (Y - mY)) / sum(w);
covXX = sum (w .* (X - mX) .* (X - mX)) / sum(w);
covYY = sum (w .* (Y - mY) .* (Y - mY)) / sum(w);

rho_w  = covXY / sqrt(covXX * covYY);
rho_2 = rho_w * rho_w;

end
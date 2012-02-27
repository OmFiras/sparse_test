%this script is used to test the sparse feature sign algorithm

%%read the test data file
if ~exist('dat','var')
    dat = csvread('2006.csv', 0,1);
end
traindim = 1500;
testdim = 500;
tpoints = (1:traindim:16000);
probe_range = 1:100:1000;
objs = cell(1, 5);

%train_probe = (1:100);
%test_probe = (1:100);
%%{
for itest = 1:5
    
for kk = 1:(size(probe_range, 2)-1)
    train_probe = (probe_range(kk):(probe_range(kk+1)-1));
    test_probe = train_probe;

    for jj = 1:(size(tpoints, 2)-2)
        train_time = (tpoints(jj):(tpoints(jj+1)-1));
        test_time = (tpoints(jj+1):(tpoints(jj+1)+testdim-1));

        % range from [500, 2000], [1500, 3000]

        %train_time = (1:1500);
        train = dat(train_probe, train_time);
        train(train==1)=0;
        train(train==-1)=1;

        % test set

        %test_time = (1501:2000);
        test = dat(test_probe, test_time);
        test(test==1)=0;
        test(test==-1)=1;

        %%{
        dictsizes = [100];
        gammas = [0.01, 0.1];
        lambdas = [0.01, 0.1];

        for igamma=1:size(gammas, 2)
            for ilambda=1:size(lambdas, 2)
                for idict=1:size(dictsizes, 2)
                    clearvars -except dat train test dictsizes gammas lambdas igamma ilambda idict train_probe train_time test_probe test_time tpoints traindim testdim itest;

                    dictsize = dictsizes(idict);
                    randdict = train(:, rand_int(1,size(train,2),dictsize,1,1,0));
                    params.probe = train_probe;
                    params.time = train_time;
                    params.test_probe = test_probe;
                    params.test_time = test_time;

                    params.test = test;
                    params.train = train;

                    params.initDict = randdict;
                    params.gamma = gammas(igamma);
                    params.lambda = lambdas(ilambda);
                    params.iternum = 10;
                    params.figure = 1;
                    params.epsilon = 0.1;

                    probestr = num2str([test_probe(1), test_probe(size(test_probe,2))]);
                    train_timestr = num2str([train_time(1), train_time(size(train_time,2))]);
                    test_timestr = num2str([test_time(1), test_time(size(test_time,2))]);

                    outpath = sprintf('tround-%d_dict-%d_gamma-%f_lambda-%f_probe-[%s]_train-[%s]_test-[%s]', itest, dictsizes(idict), gammas(igamma), lambdas(ilambda), probestr, train_timestr, test_timestr);
                    params.outpath = outpath;

                    [outD, outX, obj_func] = sparse_learning(params);
                    
                    objs{itest} = {params, obj_func, outD, outX};

                    save('result.mat', objs);
                    tsavefigures(outpath, 1);

                end
            end
        end

    end
end
end

%}

%{
dictsize = 50;
% initial the dictionary
params.test = test;
params.train = train;
train_time = (1:1500);
train = dat(1:100, train_time);
train(train==1)=0;
train(train==-1)=1;
randdict = train(:,rand_int(1,size(train,2),dictsize,1,1,0));

params.train = train;
params.initDict = randdict;
params.gamma = 0.01;
params.lambda = 0.1;
params.iternum = 15;
params.figure = 1;
params.outpath = 'test';

[outD, outX, rmse]=sparse_learning(params);

tsavefigures(outpath, 1);


%}

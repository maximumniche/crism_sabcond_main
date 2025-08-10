% Band Depth Parameter products (BDP's):
% (  note: you need to have 'BDP.m' also pulled up )

clc
clear; 
close all

% ------------------------------------------------------------------------
% ------------ DO STUFF FOR #'s 1 THROUGH 6, Thanks! ---------------------
% ------------------------------------------------------------------------
%
% # 1 ENTER YOUR IMAGE TITLE AND HEADER TITLE: -------------------------- 1

    % [Z, i] = enviread('ref_square_bilinear120.img', 'ref_square_bilinear120.hdr');
    % [Z, i] = enviread('ref_square_bicubic120.img', 'ref_square_bicubic120.hdr');
    [Z, i] = enviread('rock1side1dataCrop.img', 'rock1side1dataCrop.hdr');

%  # 2 Do YOU WANT image products for each individual BDP? -------------- 2
%          (if looking at summary products then it doesnt matter which )   
        
    image = 'y';          % 'y' or 'n'
    % image = 'n';

% # 3 Is the image VNIR or SWIR? ---------------------------------------- 3

    % imageType = 1;
      imageType = 2;        % 1 for VNIR, 2 for SWIR

% # 4 What do you want to calculate? ------------------------------------ 4
%           if you want an individual BDP:
%                   enter its number,
%           or look at all BDP's:
%                   '100' for VNIR BDP's
%                   '200' for SWIR
%           or for just summary products:
%                   '101' for VNIR summary products,
%                   '201' for SWIR

    % SummProdNum = 19;
    % SummProdNum = 100;
    % SummProdNum = 200;
    % SummProdNum = 101;
     SummProdNum = 201;
    
% # 5 Do you want to apply the plant blocker / mask ? ------------------- 5
%      ( sorry it only works for VNIR so far, its a work in progess )

    removePlantsAndTarget = 0;   % '1' masks, '0' does not
    % removePlantsAndTarget = 1;
    
% # 6 Do you want to view a histgram of the values for the BDP's? ------- 6    
          
     histo = 'n';
    % histo = 'y';

% # 7 Do you want to view a plot of the pixels within the thresholds? --- 7
%       ( you can scroll down to the BDP's and apply bounds )
    
     pPlot = 'n';        % 'y' for yes, 'n' for no
    % pPlot = 'y';


% ------------------------------------------------------------------------
% ----------------------------- ALL DONE ---------------------------------
% ------------------------------------------------------------------------

% VNIR:
% 3, 4, 5, 6, 7, 8
% SWIR: ( 898 - 2505)
% 13,14,15,16, 19, 20, 21, 23, 24, 25, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 39, 40
    
info = enviinfo(Z);

[r, c, d] = size(Z);

% DEMUD options:
% nsel = 500;     % number of items to select... paper uses 500
% k = 2;          % paper uses 2

%--------                                         % shows image of one band
%    imshow(imrotate(squeeze(Z(:, :, 210)), 90));
% imshow(squeeze(Z(:, :, 3)));
% %--------                                         % plots one pixels info 
% plot(i.wavelength, squeeze(Z(33, 39, :)));
% hold on

% -------------------------------------------------------------------------
                                                          
name = (' ');

numToPlot = 15;     % for random pixel plotting
    
binsize = 80;       % for BDP histogram 

scrsz = get(groot, 'ScreenSize');

ZBDP = zeros(r, c, 6);  % BDP cube, for clustering purposes

if ( SummProdNum == 101 || SummProdNum == 201 )
    image = 'n';
end
    

% TRU (and gray):----------------------------------------------- TRU / gray           
%       From "true color", an enhanced true color representation of 
%       the scene derived from I/F after correction for atmospheric and 
%       photometric effects

if (imageType == 1)
    
    ZcontentsnewTrue = zeros(r, c, 3);
    ZcontentsnewTrue(:, :, 1) = squeeze(Z(:, :, 124));
    ZcontentsnewTrue(:, :, 2) = squeeze(Z(:, :,  81));
    ZcontentsnewTrue(:, :, 3) = squeeze(Z(:, :,  26));

    Zgray = rgb2gray(ZcontentsnewTrue);
    
end

if (imageType == 2)
    
    [~, Ls] = min(abs(i.wavelength - 1080));
    S(:, :, 1) = double(squeeze(Z(:, :, (Ls - 2))));
    S(:, :, 2) = double(squeeze(Z(:, :, (Ls - 1))));
    S(:, :, 3) = double(squeeze(Z(:, :, Ls)));
    S(:, :, 4) = double(squeeze(Z(:, :, (Ls + 1))));
    S(:, :, 5) = double(squeeze(Z(:, :, (Ls + 2))));
    ZLow = median(S, 3);  
    
    [~, Ls] = min(abs(i.wavelength - 1506));
    S(:, :, 1) = double(squeeze(Z(:, :, (Ls - 2))));
    S(:, :, 2) = double(squeeze(Z(:, :, (Ls - 1))));
    S(:, :, 3) = double(squeeze(Z(:, :, Ls)));
    S(:, :, 4) = double(squeeze(Z(:, :, (Ls + 1))));
    S(:, :, 5) = double(squeeze(Z(:, :, (Ls + 2))));
    Zmed = median(S, 3);
    
    [~, Ls] = min(abs(i.wavelength - 2529));
    S(:, :, 1) = double(squeeze(Z(:, :, (Ls - 2))));
    S(:, :, 2) = double(squeeze(Z(:, :, (Ls - 1))));
    S(:, :, 3) = double(squeeze(Z(:, :, Ls)));
    Zhigh = median(S, 3);

    Zgray  = zeros(r, c, 3);
    Zgray(:, :, 1) = ZLow * 2;
    Zgray(:, :, 2) = Zmed * 2;
    Zgray(:, :, 3) = Zhigh * 2;

    Zgray = rgb2gray(Zgray);
    
end

% # 0 - Remove pixels:--------------------------------------------------- 0
%       To remove sky, target, plants, 

    Zremove = zeros(r, c);

    if(removePlantsAndTarget == 1)

    %  Remove sky:
    
%         Zsky = BDP('IBDP', 'no', 'no', 0, 0, 'no', numToPlot, scrsz, 261, 302, 327, 3, 3, 3, Z, i);
%         Zsky(Zsky > 0.158) = 1;
%         Zremove(Zsky == 1) = 1;
%     
%         figure('Name', 'BDP sky', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
%         imshow(imrotate(Zsky, 90))
%         colormap('jet')
%         caxis([0, max(max(Zsky))])
%         colorbar
    
    % Remove red egde: remove plants:
    
    ZredEdgeBlock = ones(r, c);
    %         ZredEdgeBlock( ZredEdge < 0 ) = 0;
    
    % 1: 550 greater than 450: check
               S(:, :, 1) = double(squeeze(Z(:, :, 31)));
               S(:, :, 2) = double(squeeze(Z(:, :, 32)));
               S(:, :, 3) = double(squeeze(Z(:, :, 33)));
               S = median(S, 3);  
               L(:, :, 1) = double(squeeze(Z(:, :, 92)));
               L(:, :, 2) = double(squeeze(Z(:, :, 93)));
               L(:, :, 3) = double(squeeze(Z(:, :, 94)));
               L = median(L, 3);   
               ZredEdge = L - S;
               ZredEdgeBlock( ZredEdge < 0 ) = 0;

    % 2: 550 greater than 650:sorta
               S(:, :, 1) = double(squeeze(Z(:, :, 154)));
               S(:, :, 2) = double(squeeze(Z(:, :, 155)));
               S(:, :, 3) = double(squeeze(Z(:, :, 156)));
               S = median(S, 3);  
               L(:, :, 1) = double(squeeze(Z(:, :, 92)));
               L(:, :, 2) = double(squeeze(Z(:, :, 93)));
               L(:, :, 3) = double(squeeze(Z(:, :, 94)));
               L = median(L, 3);   
               ZredEdge = L - S;
               ZredEdgeBlock( ZredEdge < 0 ) = 0;

    % 3: 850 greater than 550: k
               S(:, :, 1) = double(squeeze(Z(:, :, 92)));
               S(:, :, 2) = double(squeeze(Z(:, :, 93)));
               S(:, :, 3) = double(squeeze(Z(:, :, 94)));
               S = median(S, 3);  
               L(:, :, 1) = double(squeeze(Z(:, :, 226)));
               L(:, :, 2) = double(squeeze(Z(:, :, 227)));
               L(:, :, 3) = double(squeeze(Z(:, :, 228)));
               L = median(L, 3);   
               ZredEdge = L - S;
               ZredEdgeBlock( ZredEdge < 0 ) = 0;

    % 4: 950 greater than 550:k
               S(:, :, 1) = double(squeeze(Z(:, :, 92)));
               S(:, :, 2) = double(squeeze(Z(:, :, 93)));
               S(:, :, 3) = double(squeeze(Z(:, :, 94)));
               S = median(S, 3);  
               L(:, :, 1) = double(squeeze(Z(:, :, 338)));
               L(:, :, 2) = double(squeeze(Z(:, :, 339)));
               L(:, :, 3) = double(squeeze(Z(:, :, 340)));
               L = median(L, 3);   
               ZredEdge = L - S;
               ZredEdgeBlock( ZredEdge < 0 ) = 0;

    % 5: 680 edge to 730 ish greater than 0:
               S(:, :, 1) = double(squeeze(Z(:, :, 172)));
               S(:, :, 2) = double(squeeze(Z(:, :, 173)));
               S(:, :, 3) = double(squeeze(Z(:, :, 174)));
               S = median(S, 3);  
               L(:, :, 1) = double(squeeze(Z(:, :, 203)));
               L(:, :, 2) = double(squeeze(Z(:, :, 202)));
               L(:, :, 3) = double(squeeze(Z(:, :, 201)));
               L = median(L, 3);   
               ZredEdge = L - S;
               ZredEdgeBlock( ZredEdge < 0 ) = 0;
               
    % 6: 900 less than 700 ish:
    %                S(:, :, 1) = double(squeeze(Z(:, :, 184)));
    %                S(:, :, 2) = double(squeeze(Z(:, :, 185)));
    %                S(:, :, 3) = double(squeeze(Z(:, :, 186)));
    %                S = median(S, 3);  
    %                L(:, :, 1) = double(squeeze(Z(:, :, 307)));
    %                L(:, :, 2) = double(squeeze(Z(:, :, 308)));
    %                L(:, :, 3) = double(squeeze(Z(:, :, 309)));
    %                L = median(L, 3);   
    %                ZredEdge = L - S;
    %                ZredEdgeBlock( ZredEdge < 0 ) = 0;

    % 7: 900 not less than :    
               ZredEdge = double(squeeze(Z(:, :, 308)));
               ZredEdgeBlock( ZredEdge < 0.1 ) = 0;
               ZredEdgeBlock( ZredEdge > 1 ) = 0;    
    
%         figure('Name', 'BDP red edge', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
%         imshow(imrotate(ZredEdgeBlock, 90))
%         colormap('jet')
%         caxis([0, max(max(ZredEdgeBlock))])
%         colorbar
        
%         [row, col] = find(ZredEdgeBlock > 0 );    
%         randPixs = randperm(length(row), numToPlot);
% 
%         figure('Name', 'yup', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
%         for g = 1:numToPlot
%             plot(i.wavelength, squeeze(Z(row(randPixs(g)), col(randPixs(g)), :)));
%             hold on
%         end
    
    % Remove trees:
    
       % Ztree = BDP('BDP', 'no', 'no', 0, 0, 'no', numToPlot, scrsz, 93, 167, 322, 5, 5, 5, Z, i);
       % Ztree(Ztree > 0.26) = 1;
       % Zremove(Ztree == 1) = 1;
        
         %Ztree = (squeeze(Z(:, :, 65)) - squeeze(Z(:, :, 15)));
         %ZtreeBlock = (squeeze(Z(:, :, 360)) - squeeze(Z(:, :, 330)));       % will get tree, and noisy rocks
         %Ztree(ZtreeBlock < 0) = 0;
         %ZtreeBlock = (squeeze(Z(:, :, 301)) - squeeze(Z(:, :, 261)));       % gets trees and alot of others
         %Ztree(ZtreeBlock < 0) = 0;
         %Ztree = (squeeze(Z(:, :, 327)) - squeeze(Z(:, :, 301)));       % picks up center tree pixels...
         %Ztree = (squeeze(Z(:, :, 93)) - squeeze(Z(:, :, 216)));
         %Ztree(ZtreeBlock < 0) = 0;

%         figure('Name', 'BDP tree map', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
%         imshow(imrotate(Ztree, 90))
%         colormap('jet')
%         caxis([0, max(max(Ztree))])
%         colorbar
%                 
%         [row, col] = find(Ztree > 0 );    
%         randPixs = randperm(length(row), numToPlot);
% 
%         figure('Name', 'yup', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
%         for g = 1:numToPlot
%             plot(i.wavelength, squeeze(Z(row(randPixs(g)), col(randPixs(g)), :)));
%             hold on
%         end

%     % Find tree:
%         Zrocks1 = BDP('BDP', 'no', 'no', 0, 0, 'no', numToPlot, scrsz, 300, 328, 358, 3, 3, 3, Z, i);
%         Zrocks1(Zrocks1 > 0.32) = 1;
%         Zremove(Zrocks1 == 1) = 1;
%         
%         Zrocks2 = BDP('BDP', 'no', 'no', 0, 0, 'no', numToPlot, scrsz, 193, 199, 209, 3, 3, 3, Z, i);
%         Zrocks2(Zrocks2 > 0.05 | Zrocks2 < 0.015) = 0;
%         Zrocks2(Zrocks2 ~= 0) = 1;
%         
%         Zrocks3 = BDP('BDP', 'no', 'no', 0, 0, 'no', numToPlot, scrsz, 217, 224, 233, 3, 3, 3, Z, i);
%         Zrocks3(Zrocks3 > 0.1 | Zrocks3 < 0.03) = 0;
%         Zrocks3(Zrocks3 ~= 0) = 1;
%         
%         Zrocks4 = BDP('BDP', 'no', 'no', 0, 0, 'no', numToPlot, scrsz, 251, 258, 268, 3, 3, 3, Z, i);
%         Zrocks4(Zrocks4 > 0.09 | Zrocks4 < 0.02) = 0;
%         Zrocks4(Zrocks4 ~= 0) = 1;
%         
%         Zrocks5 = BDP('IBDP', 'no', 'no', 0, 0, 'no', numToPlot, scrsz, 83, 124, 195, 5, 5, 3, Z, i);
%         Zrocks5(Zrocks5 < 0.018) = 1;
%         
%         Zrocks = Zrocks2 +Zrocks3 + Zrocks4 + Zrocks5;
%         Zrocks(Zrocks ~= 4) = 0;
%         
%         Zremove(Zrocks == 4) = 1;
        
%         figure('Name', 'BDP find rocks2', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
%         imshow(imrotate(Zrocks, 90))
%         colormap('jet')
%         caxis([0, max(max(Zrocks))])
%         colorbar
        
%         % tree plots
%             rocks =  Zremove([411:507],[380:461]);
%             rWave = Z([411:507],[380:461], :);
% 
%             [row, col] = find(rocks == 0 );    
%             randPixs = randperm(length(row), numToPlot);
% 
%             figure('Name', 'trees maybe', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
% 
%             for g = 1:30
%                 plot(squeeze(rWave(row(randPixs(g)), col(randPixs(g)), :)));
%                 hold on
%             end
%         %
    
    end
    
% ------------------------------------------------------------------------    
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% ------------------------- BDP Start Here ! -----------------------------
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
% ------------------------------------------------------------------------
    

% # 1 - R770:------------------------------------------------------------ 1
%       0.77 um reflectance
%       Rationale: Higher value more dusty or icy
%       Caveats: Sensitive to slope effects, clouds

%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 1 || SummProdNum == 100)
        
       Zcontentsnew1 = zeros(r, c, 3);

       Z1(:, :, 1) = double(squeeze(Z(:, :, 226)));
       Z1(:, :, 2) = double(squeeze(Z(:, :, 227)));
       Z1(:, :, 3) = double(squeeze(Z(:, :, 228)));
       Z1(:, :, 4) = double(squeeze(Z(:, :, 229)));
       Z1(:, :, 5) = double(squeeze(Z(:, :, 230)));
       Z1 = median(Z1, 3);
       Z1(Zremove > 0) = 0;
       Z1(Z1 > 0.3) = 0;
       
       Zcontentsnew1(:, :, 1) = Z1;

       if (strcmp(image, 'y'))

           figure('Name', 'BDP 1', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
           imshow(imrotate(Z1, 90));
           colormap('jet')
           caxis([0, max(max(Z1))])
           colorbar
           
       end
       
    end


% # 2 - RBR:------------------------------------------------------------- 2
%       Red/blue ratio
%       Rationale: Higher value indicates more npFeOx
%       Caveats: Sensitive to dust in atmosphere

%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 2 ) %|| SummProdNum == 100)
        
       Zcontentsnew2 = zeros(r, c, 3);

       Z2s = zeros(975, 461, 5);
       Z2s(:, :, 1) = double(squeeze(Z(:, :, 24)));
       Z2s(:, :, 2) = double(squeeze(Z(:, :, 25)));
       Z2s(:, :, 3) = double(squeeze(Z(:, :, 26)));
       Z2s(:, :, 4) = double(squeeze(Z(:, :, 27)));
       Z2s(:, :, 5) = double(squeeze(Z(:, :, 28)));
       Z2s = median(Z2s, 3);
       
       Z2l = zeros(975, 461, 5);
       Z2l(:, :, 1) = double(squeeze(Z(:, :, 226)));
       Z2l(:, :, 2) = double(squeeze(Z(:, :, 227)));
       Z2l(:, :, 3) = double(squeeze(Z(:, :, 228)));
       Z2l(:, :, 4) = double(squeeze(Z(:, :, 229)));
       Z2l(:, :, 5) = double(squeeze(Z(:, :, 230)));
       Z2l = median(Z2l, 3);
       
       Z2 = Z2l ./ Z2s;
       Z2(Z2 > 2.2) = 0;
       Z2(Zremove > 0) = 0;
       
       if (strcmp(image, 'y'))
           figure('Name', 'BDP 2', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
           imshow(imrotate(Z2, 90))
           colormap('jet')
           caxis([0, max(max(Z2))])
           colorbar
       end
       
    end

% # 3 - BD530_2:--------------------------------------------------------- 3
%       Parameter: 530 nanometer band depth
%       Formulation: BDP
%       Kernel Width: 5-440, 5-530, 5-614 
%       Rationale: Higher value has more fine-grained crystalline hematite
%       Caveats: N/A
%       Histogram bins:
%       Image threshold: 0 to 0.17
%       Notes: for 'fine-grained crystalline hematite'

    if(SummProdNum == 3 || SummProdNum == 100 || SummProdNum == 101)
                
        imageThresh = 0.3;
        imageT = 'Band Depth 3';
        heatmapT = 'Band Depth 3 heatmap';
        hTitle = 'Band Depth 3 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 3 Parameter Pixel Plot';
        Ls = 440;
        Lc = 530;
        Ll = 614;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z3 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
        ZBDP(:, :, 1) = Z3;
        
    end

% # 4 - SH600_2:--------------------------------------------------------- 4
%       Parameter: 600 nanometer shoulder height
%       Formulation: IBDP
%       Kernel Width: 5-533, 5-600, 3-716
%       Rationale: Select ferric minerals (especially hematite and 
%           goethite) or compacted texture
%       Caveats: Sensitive to high opacity in atmosphere
%       Histogram bins: -0.15 to 0.2
%       Image threshold: 0.2
%       Notes:

    if(SummProdNum == 4 || SummProdNum == 100 || SummProdNum == 101)
        
        imageThresh = 0.2;
        imageT = 'Band Depth 4';
        heatmapT = 'Band Depth 4 heatmap';
        hTitle = 'Band Depth 4 Parameter Histogram';
        bLow = -0.15;
        bHigh = 0.2;
        pTitle = 'Band Depth 4 Parameter Pixel Plot';
        Ls = 533;
        Lc = 600;
        Ll = 716;
        Ks = 5;
        Kc = 5;
        Kl = 3;
        
        Z4 = BDP('IBDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
        ZBDP(:, :, 2) = Z4;
        
    end

% # 5 - SH770:----------------------------------------------------------- 5
%       Parameter: 770 shoulder height
%       Formulation: IBDP
%       Kernel Width: 3-716, 5-775, 5-860
%       Rationale: Select ferric minerals, less sensitive to LCP than SH600_2
%       Caveats: Sensitive to high opacity in atmosphere
%       Histogram bins:
%       Image threshold: 0 to 0.075
%       Notes:

    if(SummProdNum == 5 || SummProdNum == 100 || SummProdNum == 101)
  
        imageThresh = 0.075;
        imageT = 'Band Depth 5';
        heatmapT = 'Band Depth 5 heatmap';
        hTitle = 'Band Depth 5 Parameter Histogram';
        bLow = -0.05;
        bHigh = 0.2;
        pTitle = 'Band Depth 5 Parameter Pixel Plot';
        Ls = 716;
        Lc = 775;
        Ll = 860;
        Ks = 3;
        Kc = 5;
        Kl = 5;
        
        Z5 = BDP('IBDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
        ZBDP(:, :, 3) = Z5;
        
    end

% # 6 - BD640_2:--------------------------------------------------------- 6
%       Parameter: 640 nanometer band depth
%       Formulation: BDP
%       Kernel Width: 5-600, 3-624, 5-760
%       Rationale: Select ferric minerals (especially maghemite)
%       Caveats: Obscured by VNIR  detector artifact
%       Histogram bins: -0.1 to 0.15
%       Image threshold: 0 to 0.06
%       Notes: negative values show up like the expected positive ones
%               should

    if(SummProdNum == 6 || SummProdNum == 100)
 
        imageThresh = 0.06;
        imageT = 'Band Depth 6';
        heatmapT = 'Band Depth 6 heatmap';
        hTitle = 'Band Depth 6 Parameter Histogram';
        bLow = -0.1;
        bHigh = 0.15;
        pTitle = 'Band Depth 6 Parameter Pixel Plot';
        Ls = 600;
        Lc = 624;
        Ll = 760;
        Ks = 5;
        Kc = 3;
        Kl = 5;
        
        Z6 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
        ZBDP(:, :, 4) = Z6;
        
    end

% # 7 - BD860_2:--------------------------------------------------------- 7
%       Parameter: 860 band depth
%       Formulation: BDP
%       Kernel Width: 5-755, 5-860, 5-977
%       Rationale: Select crystalline ferric minerals (especially hematite)
%       Caveats: N/A
%       Histogram bins: -0.25 to 0.2
%       Image threshold: 0 to 0.085
%       Notes:

    if(SummProdNum == 7 || SummProdNum == 100)
        
        imageThresh = 0.085;
        imageT = 'Band Depth 7';
        heatmapT = 'Band Depth 7 heatmap';
        hTitle = 'Band Depth 7 Parameter Histogram';
        bLow = -0.25;
        bHigh = 0.2;
        pTitle = 'Band Depth 7 Parameter Pixel Plot';
        Ls = 755;
        Lc = 860;
        Ll = 977;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z7 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
        ZBDP(:, :, 5) = Z7;
        
    end

% # 8 - BD920_2:--------------------------------------------------------- 8
%       Parameter: 920 nanometer band depth
%       Formulation: BDP
%       Kernel Width: 5-807, 5-920, 5-984
%       Rationale: for 'Crystalline ferric minerals and LCP'
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 8 || SummProdNum == 100)
        
        imageThresh = 0.14;
        imageT = 'Band Depth 8';
        heatmapT = 'Band Depth 8 heatmap';
        hTitle = 'Band Depth 8 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 8 Parameter Pixel Plot';
        Ls = 807;
        Lc = 920;
        Ll = 984;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z8 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        
        ZBDP(:, :, 6) = Z8;
        
    end

% # 9 - RPEAK1 :--------------------------------------------------------- 9           
%       Parameter: reflectance peak 1
%       Formulation: Wave length where 1st derivative = 0 of fifth order
%           polynomial fit to reflectances at all valid VNIR wavelengths: 
%           R600, R648, R680, R710, R740, R770, R800, R830.
%       Kernel Width: N/A
%       Rationale: Fe minerology (<0.75 suggests olivine, about 0.75
%           suggests pyroxene, >0.8 dust)
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

%     if(SummProdNum == 9 || SummProdNum == 100)
%             ZcontentsnewRPeak = zeros(975, 461, 8);

%             ZcontentsnewRPeak(:, :, 1) = squeeze(Z(:, :, 124));  % R600
%             ZcontentsnewRPeak(:, :, 2) = squeeze(Z(:, :, 154));  % R648
%             ZcontentsnewRPeak(:, :, 3) = squeeze(Z(:, :, 173));  % R680
%             ZcontentsnewRPeak(:, :, 4) = squeeze(Z(:, :, 191));  % R710
%             ZcontentsnewRPeak(:, :, 5) = squeeze(Z(:, :, 210));  % R740
%             ZcontentsnewRPeak(:, :, 6) = squeeze(Z(:, :, 228));  % R770
%             ZcontentsnewRPeak(:, :, 7) = squeeze(Z(:, :, 247));  % R800
%             ZcontentsnewRPeak(:, :, 8) = squeeze(Z(:, :, 265));  % R830
% 
%             x = [600 648 680 710 740 770 800 830];
% 
%             xxx = polyfit(ZcontentsnewRPeak(:, :, 1:8), x, 'poly5');
% 
%                             [Zcontentsnew9(r, c), ~] = fit( squeeze(Z(r, c, :)), i.wavelength', 'poly5');
%                              Zcontentsnew9(r, c, 1:5) = polyfit(squeeze(Z(r, c, :)), i.wavelength', 5);
%     end

% # 10 - BDI1000VIS :--------------------------------------------------- 10
%       Parameter: 1000 nanometer integrated band depth; VNIR wavelengths
%       Formulation: Divide reflectances from R833 to R1023 by the modeled
%               reflectance at RPEAK1, then integrate over (1 - normalized
%               radiances) to get get integrated band depth
%       Kernel Width: N/A
%       Rationale: olivine, pyroxine, or Fe bearing glass
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

% # 11 - BDI1000IR :---------------------------------------------------- 11
%       Parameter: 1000 nanometer integrated band depth; IR wavelengths
%       Formulation: Divide reflectances from R1045 to R1255 by linear fit
%               from median R(of the 15) between 1300 and 1870 nanometers
%               to median R between 2430 and 2600 extrapolated backward,
%               then integrate over (1 - normalized radiances) to get
%               integrated band deph 
%       Kernel Width: N/A
%       Rationale: Crystalline Fe^2^+ silicates
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 12 - R1330 :-------------------------------------------------------- 12
%       Parameter: IR albedo
%       Formulation: R1330
%       Kernel Width: 11-1330
%       Rationale: IR albedo (ices > dust > unaltered mafics)
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

%      if(SummProdNum == 12 || SummProdNum == 100)
%          
%         Z12(:, :,  1) = double(squeeze(Z(:, :, 1330 - 5)));
%         Z12(:, :,  2) = double(squeeze(Z(:, :, 1330 - 4)));
%         Z12(:, :,  3) = double(squeeze(Z(:, :, 1330 - 3)));
%         Z12(:, :,  4) = double(squeeze(Z(:, :, 1330 - 2)));
%         Z12(:, :,  5) = double(squeeze(Z(:, :, 1330 - 1)));
%         Z12(:, :,  6) = double(squeeze(Z(:, :, 1330 )));
%         Z12(:, :,  7) = double(squeeze(Z(:, :, 1330 + 1)));
%         Z12(:, :,  8) = double(squeeze(Z(:, :, 1330 + 2)));
%         Z12(:, :,  9) = double(squeeze(Z(:, :, 1330 + 3)));
%         Z12(:, :, 10) = double(squeeze(Z(:, :, 1330 + 4)));
%         Z12(:, :, 11) = double(squeeze(Z(:, :, 1330 + 5)));
%         
%         Z12 = median(Z12, 3);
%         Z12(Zremove > 0) = 0;
%         %Z12(Z12 > 0.) = 0;
%        
%         Zcontentsnew12 = zeros(975, 461, 3);
%         Zcontentsnew12(:, :, 1) = Z12;
% 
%         figure('Name', 'BDP 12', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
%         imshow(imrotate(Z12, 90));
%         colormap('jet')
%         caxis([0, max(max(Z12))])
%         colorbar
%          
%      end


% # 13 - BD1300 :------------------------------------------------------- 13
%       Status: Significantly modified or new product
%       Parameter: 1300 nanometer absorption associated with Fe^2^+
%               substitution in plagioclase
%       Formulation: BDP
%       Kernel Width: 5-1370, 15-1432, 5-1470
%       Rationale: Plagioclase with Fe^2^+ substitution
%       Caveats: Fe-Olivine can be > 0
%       Histogram bins:
%       Image threshold:
%       Notes:

      if(SummProdNum == 13 || SummProdNum == 200)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 13';
        heatmapT = 'Band Depth 13 heatmap';
        hTitle = 'Band Depth 13 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 13 Parameter Pixel Plot';
        Ls = 1080;
        Lc = 1320;
        Ll = 1750;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z13 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

      end

% # 14 - OLINDEX3 :----------------------------------------------------- 14
%       Parameter: Detect broad absorption centered at 1000 nanometers
%       Formulation:
%       Kernel Width: 7 for all 7
%       Rationale: Olivines will be strongly > 0
%       Caveats: HCP, Fe-phyllosilicates
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 14 || SummProdNum == 200 || SummProdNum == 201)
        
        imageT = 'Band Depth 14';
        imageThresh = 0.3;
        bLow = -0.3;
        bHigh = 0.3;

        [~, Ln1] = min(abs(i.wavelength - 1080));
        LnOne(:, :, 1) = double(squeeze(Z(:, :, Ln1 - 2 )))  ;
        LnOne(:, :, 2) = double(squeeze(Z(:, :, (Ln1 - 1) )))  ;
        LnOne(:, :, 3) = double(squeeze(Z(:, :, Ln1 )))  ;
        LnOne(:, :, 4) = double(squeeze(Z(:, :, Ln1 + 1 )))  ;
        LnOne(:, :, 5) = double(squeeze(Z(:, :, Ln1 + 2 )))  ;
        Ln1 = mean(LnOne, 3) .* 0.03;
        
        [~, Ln2] = min(abs(i.wavelength - 1152));
        LnTwo(:, :, 1) = double(squeeze(Z(:, :, Ln2 - 2 )))  ;
        LnTwo(:, :, 2) = double(squeeze(Z(:, :, (Ln2 - 1) )))  ;
        LnTwo(:, :, 3) = double(squeeze(Z(:, :, Ln2 )))  ;
        LnTwo(:, :, 4) = double(squeeze(Z(:, :, Ln2 + 1 )))  ;
        LnTwo(:, :, 5) = double(squeeze(Z(:, :, Ln2 + 2 )))  ;
        Ln2 = mean(LnTwo, 3) .* 0.03;
        
        [~, Ln3] = min(abs(i.wavelength - 1210));
        LnThree(:, :, 1) = double(squeeze(Z(:, :, Ln3 - 2 )))  ;
        LnThree(:, :, 2) = double(squeeze(Z(:, :, (Ln3 - 1) )))  ;
        LnThree(:, :, 3) = double(squeeze(Z(:, :, Ln3 )))  ;
        LnThree(:, :, 4) = double(squeeze(Z(:, :, Ln3 + 1 )))  ;
        LnThree(:, :, 5) = double(squeeze(Z(:, :, Ln3 + 2 )))  ;
        Ln3 = mean(LnThree, 3) .* 0.03;
        
        [~, Ln4] = min(abs(i.wavelength - 1250));
        LnFour(:, :, 1) = double(squeeze(Z(:, :, Ln4 - 2 )))  ;
        LnFour(:, :, 2) = double(squeeze(Z(:, :, (Ln4 - 1) )))  ;
        LnFour(:, :, 3) = double(squeeze(Z(:, :, Ln4 )))  ;
        LnFour(:, :, 4) = double(squeeze(Z(:, :, Ln4 + 1 )))  ;
        LnFour(:, :, 5) = double(squeeze(Z(:, :, Ln4 + 2 )))  ;
        Ln4 = mean(LnFour, 3) .* 0.03;
        
        [~, Ln5] = min(abs(i.wavelength - 1263));
        LnFive(:, :, 1) = double(squeeze(Z(:, :, Ln5 - 2 )))  ;
        LnFive(:, :, 2) = double(squeeze(Z(:, :, (Ln5 - 1) )))  ;
        LnFive(:, :, 3) = double(squeeze(Z(:, :, Ln5 )))  ;
        LnFive(:, :, 4) = double(squeeze(Z(:, :, Ln5 + 1 )))  ;
        LnFive(:, :, 5) = double(squeeze(Z(:, :, Ln5 + 2 )))  ;
        Ln5 = mean(LnFive, 3) .* 0.07;
        
        [~, Ln6] = min(abs(i.wavelength - 1276));
        LnSix(:, :, 1) = double(squeeze(Z(:, :, Ln6 - 2 )))  ;
        LnSix(:, :, 2) = double(squeeze(Z(:, :, (Ln6 - 1) )))  ;
        LnSix(:, :, 3) = double(squeeze(Z(:, :, Ln6 )))  ;
        LnSix(:, :, 4) = double(squeeze(Z(:, :, Ln6 + 1 )))  ;
        LnSix(:, :, 5) = double(squeeze(Z(:, :, Ln6 + 2 )))  ;
        Ln6 = mean(LnSix, 3) .* 0.07;
        
        [~, Ln7] = min(abs(i.wavelength - 1330));
        LnSeven(:, :, 1) = double(squeeze(Z(:, :, Ln7 - 2 )))  ;
        LnSeven(:, :, 2) = double(squeeze(Z(:, :, (Ln7 - 1) )))  ;
        LnSeven(:, :, 3) = double(squeeze(Z(:, :, Ln7 )))  ;
        LnSeven(:, :, 4) = double(squeeze(Z(:, :, Ln7 + 1 )))  ;
        LnSeven(:, :, 5) = double(squeeze(Z(:, :, Ln7 + 2 )))  ;
        Ln7 = mean(LnSeven, 3) .* 0.12;
        
        [~, Ln8] = min(abs(i.wavelength - 1368));
        LnEight(:, :, 1) = double(squeeze(Z(:, :, Ln8 - 2 )))  ;
        LnEight(:, :, 2) = double(squeeze(Z(:, :, (Ln8 - 1) )))  ;
        LnEight(:, :, 3) = double(squeeze(Z(:, :, Ln8 )))  ;
        LnEight(:, :, 4) = double(squeeze(Z(:, :, Ln8 + 1 )))  ;
        LnEight(:, :, 5) = double(squeeze(Z(:, :, Ln8 + 2 )))  ;
        Ln8 = mean(LnEight, 3) .* 0.12;
        
        [~, Ln9] = min(abs(i.wavelength - 1395));
        LnNine(:, :, 1) = double(squeeze(Z(:, :, Ln9 - 2 )))  ;
        LnNine(:, :, 2) = double(squeeze(Z(:, :, (Ln9 - 1) )))  ;
        LnNine(:, :, 3) = double(squeeze(Z(:, :, Ln9 )))  ;
        LnNine(:, :, 4) = double(squeeze(Z(:, :, Ln9 + 1 )))  ;
        LnNine(:, :, 5) = double(squeeze(Z(:, :, Ln9 + 2 )))  ;
        Ln9 = mean(LnNine, 3) .* 0.14;
        
        [~, Ln10] = min(abs(i.wavelength - 1427));
        LnTen(:, :, 1) = double(squeeze(Z(:, :, Ln10 - 2 )))  ;
        LnTen(:, :, 2) = double(squeeze(Z(:, :, (Ln10 - 1) )))  ;
        LnTen(:, :, 3) = double(squeeze(Z(:, :, Ln10 )))  ;
        LnTen(:, :, 4) = double(squeeze(Z(:, :, Ln10 + 1 )))  ;
        LnTen(:, :, 5) = double(squeeze(Z(:, :, Ln10 + 2 )));
        Ln10 = mean(LnTen, 3) .* 0.18;
        
        [~, Ln11] = min(abs(i.wavelength - 1470));
        LnEleven(:, :, 1) = double(squeeze(Z(:, :, Ln11 - 2 )));
        LnEleven(:, :, 2) = double(squeeze(Z(:, :, (Ln11 - 1) )));
        LnEleven(:, :, 3) = double(squeeze(Z(:, :, Ln11 )));
        LnEleven(:, :, 4) = double(squeeze(Z(:, :, Ln11 + 1 )));
        LnEleven(:, :, 5) = double(squeeze(Z(:, :, Ln11 + 2 )));
        Ln11 = mean(LnEleven, 3) .* 0.18;

        Z14 = Ln1 + Ln2 + Ln3 + Ln4 + Ln5 + Ln6 + Ln7 + Ln8 + Ln9 + Ln10 + Ln11;
        
        Z14(Zremove > 0) = 0;
        Z14(Z14 < 0) = 0;
        Z14(Z14 > imageThresh) = 0;
        
        if (strcmp(image, 'y') && SummProdNum ~= 201)
            
           Zcontentsnew = zeros(r, c, 3);
           Zcontentsnew(:, :, 1) = Z14 * 2;
           figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
           imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90)); 
            
           figure('Name', 'BDP 14', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
           imshow(imrotate(Z14, 90))
           colormap('jet')
           caxis([0, max(max(Z14))])
           colorbar
           
        end
       
    end

% # 15 - LCPINDEX2 :---------------------------------------------------- 15
%       Status: Significantly modified or new product
%       Parameter: Detect broad absorption centered at 1810 nanometers
%       Formulation:
%       Kernel Width: 7 for all 6
%       Rationale: Pyroxene is strongly +; favors LCP
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 15 || SummProdNum == 200 || SummProdNum == 201)
        
        imageT = 'Band Depth 15';
        imageThresh = 0.3;
        bLow = -0.3;
        bHigh = 0.3;

        [~, Ln1] = min(abs(i.wavelength - 1690));
        LnOne(:, :, 1) = double(squeeze(Z(:, :, Ln1 - 2 )))  ;
        LnOne(:, :, 2) = double(squeeze(Z(:, :, (Ln1 - 1) )))  ;
        LnOne(:, :, 3) = double(squeeze(Z(:, :, Ln1 )))  ;
        LnOne(:, :, 4) = double(squeeze(Z(:, :, Ln1 + 1 )))  ;
        LnOne(:, :, 5) = double(squeeze(Z(:, :, Ln1 + 2 )))  ;
        Ln1 = mean(LnOne, 3) .* 0.2;
        
        [~, Ln2] = min(abs(i.wavelength - 1750));
        LnTwo(:, :, 1) = double(squeeze(Z(:, :, Ln2 - 2 )))  ;
        LnTwo(:, :, 2) = double(squeeze(Z(:, :, (Ln2 - 1) )))  ;
        LnTwo(:, :, 3) = double(squeeze(Z(:, :, Ln2 )))  ;
        LnTwo(:, :, 4) = double(squeeze(Z(:, :, Ln2 + 1 )))  ;
        LnTwo(:, :, 5) = double(squeeze(Z(:, :, Ln2 + 2 )))  ;
        Ln2 = mean(LnTwo, 3) .* 0.2;
        
        [~, Ln3] = min(abs(i.wavelength - 1810));
        LnThree(:, :, 1) = double(squeeze(Z(:, :, Ln3 - 2 )))  ;
        LnThree(:, :, 2) = double(squeeze(Z(:, :, (Ln3 - 1) )))  ;
        LnThree(:, :, 3) = double(squeeze(Z(:, :, Ln3 )))  ;
        LnThree(:, :, 4) = double(squeeze(Z(:, :, Ln3 + 1 )))  ;
        LnThree(:, :, 5) = double(squeeze(Z(:, :, Ln3 + 2 )))  ;
        Ln3 = mean(LnThree, 3) .* 0.3;
        
        [~, Ln4] = min(abs(i.wavelength - 1870));
        LnFour(:, :, 1) = double(squeeze(Z(:, :, Ln4 - 2 )))  ;
        LnFour(:, :, 2) = double(squeeze(Z(:, :, (Ln4 - 1) )))  ;
        LnFour(:, :, 3) = double(squeeze(Z(:, :, Ln4 )))  ;
        LnFour(:, :, 4) = double(squeeze(Z(:, :, Ln4 + 1 )))  ;
        LnFour(:, :, 5) = double(squeeze(Z(:, :, Ln4 + 2 )))  ;
        Ln4 = mean(LnFour, 3) .* 0.3;
        
        Z15 = Ln1 + Ln2 + Ln3 + Ln4;
        
        Z15(Zremove > 0) = 0;
        Z15(Z15 < 0) = 0;
        Z15(Z15 > imageThresh) = 0;
        
        if (strcmp(image, 'y') && SummProdNum ~= 201)
            
           Zcontentsnew = zeros(r, c, 3);
           Zcontentsnew(:, :, 1) = Z15 * 2;
           figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
           imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));
           
           figure('Name', 'BDP 15', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
           imshow(imrotate(Z15, 90))
           colormap('jet')
           caxis([0, max(max(Z15))])
           colorbar
           
        end
        
    end

% # 16 - HCPINDEX2 :---------------------------------------------------- 16
%       Status: Significantly modified or new product
%       Parameter: Detect broad absorption centered at 2120 nanometers
%       Formulation:
%       Kernel Width: 7 for 1810, 2140, 2230, 2250, 2430, 2460, 2530
%                     5 for 2120
%       Rationale: Pyroxene is strongly +; favors HCP
%       Caveats: LCP
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 16 || SummProdNum == 200 || SummProdNum == 201)
        
        imageT = 'Band Depth 16';
        imageThresh = 0.3;
        bLow = -0.3;
        bHigh = 0.3;

        [~, Ln1] = min(abs(i.wavelength - 2120));
        LnOne(:, :, 1) = double(squeeze(Z(:, :, Ln1 - 2 )))  ;
        LnOne(:, :, 2) = double(squeeze(Z(:, :, (Ln1 - 1) )))  ;
        LnOne(:, :, 3) = double(squeeze(Z(:, :, Ln1 )))  ;
        LnOne(:, :, 4) = double(squeeze(Z(:, :, Ln1 + 1 )))  ;
        LnOne(:, :, 5) = double(squeeze(Z(:, :, Ln1 + 2 )))  ;
        Ln1 = mean(LnOne, 3) .* 0.1;
        
        [~, Ln2] = min(abs(i.wavelength - 2140));
        LnTwo(:, :, 1) = double(squeeze(Z(:, :, Ln2 - 2 )))  ;
        LnTwo(:, :, 2) = double(squeeze(Z(:, :, (Ln2 - 1) )))  ;
        LnTwo(:, :, 3) = double(squeeze(Z(:, :, Ln2 )))  ;
        LnTwo(:, :, 4) = double(squeeze(Z(:, :, Ln2 + 1 )))  ;
        LnTwo(:, :, 5) = double(squeeze(Z(:, :, Ln2 + 2 )))  ;
        Ln2 = mean(LnTwo, 3) .* 0.1;
        
        [~, Ln3] = min(abs(i.wavelength - 2230));
        LnThree(:, :, 1) = double(squeeze(Z(:, :, Ln3 - 2 )))  ;
        LnThree(:, :, 2) = double(squeeze(Z(:, :, (Ln3 - 1) )))  ;
        LnThree(:, :, 3) = double(squeeze(Z(:, :, Ln3 )))  ;
        LnThree(:, :, 4) = double(squeeze(Z(:, :, Ln3 + 1 )))  ;
        LnThree(:, :, 5) = double(squeeze(Z(:, :, Ln3 + 2 )))  ;
        Ln3 = mean(LnThree, 3) .* 0.15;
        
        [~, Ln4] = min(abs(i.wavelength - 2250));
        LnFour(:, :, 1) = double(squeeze(Z(:, :, Ln4 - 2 )))  ;
        LnFour(:, :, 2) = double(squeeze(Z(:, :, (Ln4 - 1) )))  ;
        LnFour(:, :, 3) = double(squeeze(Z(:, :, Ln4 )))  ;
        LnFour(:, :, 4) = double(squeeze(Z(:, :, Ln4 + 1 )))  ;
        LnFour(:, :, 5) = double(squeeze(Z(:, :, Ln4 + 2 )))  ;
        Ln4 = mean(LnFour, 3) .* 0.3;
        
        [~, Ln5] = min(abs(i.wavelength - 2430));
        LnFive(:, :, 1) = double(squeeze(Z(:, :, Ln5 - 2 )))  ;
        LnFive(:, :, 2) = double(squeeze(Z(:, :, (Ln5 - 1) )))  ;
        LnFive(:, :, 3) = double(squeeze(Z(:, :, Ln5 )))  ;
        LnFive(:, :, 4) = double(squeeze(Z(:, :, Ln5 + 1 )))  ;
        LnFive(:, :, 5) = double(squeeze(Z(:, :, Ln5 + 2 )))  ;
        Ln5 = mean(LnFive, 3) .* 0.2;
        
        [~, Ln6] = min(abs(i.wavelength - 2460));
        LnSix(:, :, 1) = double(squeeze(Z(:, :, Ln6 - 2 )))  ;
        LnSix(:, :, 2) = double(squeeze(Z(:, :, (Ln6 - 1) )))  ;
        LnSix(:, :, 3) = double(squeeze(Z(:, :, Ln6 )))  ;
        LnSix(:, :, 4) = double(squeeze(Z(:, :, Ln6 + 1 )))  ;
        LnSix(:, :, 5) = double(squeeze(Z(:, :, Ln6 + 2 )))  ;
        Ln6 = mean(LnSix, 3) .* 0.15;

        Z16 = Ln1 + Ln2 + Ln3 + Ln4 + Ln5 + Ln6;
        
        Z16(Zremove > 0) = 0;
        Z16(Z16 < 0) = 0;
        Z16(Z16 > imageThresh) = 0;
        
        if (strcmp(image, 'y') && SummProdNum ~= 201)
            
           Zcontentsnew = zeros(r, c, 3);
           Zcontentsnew(:, :, 1) = Z16 * 2;
           figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
           imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));
           
           figure('Name', 'BDP 16', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
           imshow(imrotate(Z16, 90))
           colormap('jet')
           caxis([0, max(max(Z16))])
           colorbar
           
        end
        
    end

% # 17 - VAR :---------------------------------------------------------- 17
%       Parameter: 1000 to 2300 nanometer specral variance
%       Formulation: Fit a line from 1000 to 2300 nanometers and find
%               variance of observed values from fit values by summing in
%               quadrature over the intervening wavelengths
%       Kernel Width: N/A
%       Rationale: OI and Px will have high values: (to be used with mafic
%               indices)
%       Caveats: Ices
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 18 - ISLOPE1 :------------------------------------------------------ 18
%       Parameter: Spectral slope 1
%       Formulation:
%       Kernel Width: 5-1815, 5-2530
%       Rationale: Ferric coating on dark rock
%       Caveats: Shaded slopes illuminated by atmospheric scatter
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 19 - BD1400 :------------------------------------------------------- 19
%       Parameter: 1400 nanometer H2O and -OH band depth
%       Formulation: BDP
%       Kernel Width: ? 5-1370 (1330?), 3-1432(1395?), 5-1470(1467)
%       Rationale: Hydrated o hydroxylated minerals
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 19 || SummProdNum == 200)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 19';
        heatmapT = 'Band Depth 19 heatmap';
        hTitle = 'Band Depth 19 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 19 Parameter Pixel Plot';
        Ls = 1330;
        Lc = 1395;
        Ll = 1467;
        Ks = 5;
        Kc = 3;
        Kl = 5;
        
        Z19 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end

% # 20 - BD1435 :------------------------------------------------------- 20
%       Parameter: 1435 nanometer CO2 ice band depth
%       Formulation: BDP
%       Kernel Width: 3-1370, 1-1432(?1435), 3-1470
%       Rationale: CO2 ice, some hydrated minerals
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 20 || SummProdNum == 22 || SummProdNum == 200)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 20';
        heatmapT = 'Band Depth 20 heatmap';
        hTitle = 'Band Depth 20 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 20 Parameter Pixel Plot';
        Ls = 1370;      
        Lc = 1435;
        Ll = 1470;
        Ks = 3;
        Kc = 3;
        Kl = 3;
        
        Z20 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 21 - BD1500 :------------------------------------------------------- 21
%       Parameter: 1500 nanometer H2O ice band depth
%       Formulation: BDP
%       Kernel Width: 5-1367, 11-1525, 5-1808
%       Rationale: H2O ice on surface or in atmosphere
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 21 || SummProdNum == 22 || SummProdNum == 200)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 21';
        heatmapT = 'Band Depth 21 heatmap';
        hTitle = 'Band Depth 21 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 21 Parameter Pixel Plot';
        Ls = 1367;
        Lc = 1525;
        Ll = 1808;
        Ks = 5;
        Kc = 7;
        Kl = 5;
        
        Z21 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end

% # 22 - ICER1 2 :------------------------------------------------------ 22
%       Parameter: CO2 and H2O ice band depth ratio
%       Formulation: uses BDP 20 and 21
%       Kernel Width: N/A
%       Rationale: CO2 H2O ice mixtures; >1 for more CO2, <1 for more water
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

%      if(SummProdNum == 22 || SummProdNum == 100)
%         
%         imageT = 'Band Depth 22';
%         heatmapT = 'Band Depth 22 heatmap';
%         hTitle = 'Band Depth 22 Parameter Histogram';
%         pTitle = 'Band Depth 22 Parameter Pixel Plot';
%         
%         Z22 = 1 - ( (1 - Z20)/(1 - Z21) ); % fix for matrix operations
%   
%      end
     
% # 23 - BD1750 :------------------------------------------------------- 23
%       Parameter: 1700 nanometer H2O band depth
%       Formulation: BDP
%       Kernel Width: 5-1690, 3-1750, 5-1815
%       Rationale: Gypsum, Alunite
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 23 || SummProdNum == 200)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 23';
        heatmapT = 'Band Depth 23 heatmap';
        hTitle = 'Band Depth 23 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 23 Parameter Pixel Plot';
        Ls = 1690;
        Lc = 1750;
        Ll = 1815;
        Ks = 5;
        Kc = 3;
        Kl = 5;
        
        Z23 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 24 - BD1900 :------------------------------------------------------- 24
%       Status: Significantly modified or new product
%       Parameter: 1900 nanometer H2O band depth
%       Formulation:
%       Kernel Width: 5-1850, 5-1930, 5-1985, 5-2016(?2067)
%       Rationale: Bound molecular H2O except monohydrated sulfates 
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 24 || SummProdNum == 200 || SummProdNum == 201)
    
        imageThresh = 0.3;
        imageT = 'Band Depth 24';
        heatmapT = 'Band Depth 24 heatmap';
        hTitle = 'Band Depth 24 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 24 Parameter Pixel Plot';
        
        Ls = 1850;
        Lc = 1930;
        Ll = 2067;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z24a = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);   
        
        Ls = 1850;
        Lc = 1985;
        Ll = 2067;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        Z24b = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
        
        Z24 = (Z24a .* 0.5) + (Z24b .* 0.5);
                
        Z24(Zremove > 0) = 0;
        Z24(Z24 < 0) = 0;
        Z24(Z24 > imageThresh) = 0;
        
        if (strcmp(image, 'y') && SummProdNum ~= 201)
                Zcontentsnew = zeros(r, c, 3);

                Zcontentsnew(:, :, 1) = Z24 * 2;

                figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));

                figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(Z24, 90))
                colormap('jet')
                caxis([0, max(max(Z24))])
                colorbar
        end
        
    end

% # 25 - BD1900r2 :----------------------------------------------------- 25
%       Status: Significantly modified or new product
%       Parameter: 1900 nanometer H2O band depth
%       Formulation:
%       Kernel Width: N/A
%       Rationale: H2O
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 25 || SummProdNum == 200 || SummProdNum == 201)
    
        imageThresh = 0.3;
        imageT = 'Band Depth 25';
        heatmapT = 'Band Depth 25 heatmap';
        bLow = -0.3;
        bHigh = 0.3;
         
        [~, Ln1] = min(abs(i.wavelength - 1908));
        Ln1 = double(squeeze(Z(:, :, Ln1 ))) ./ 1908;
        [~, Ln2] = min(abs(i.wavelength - 1914));
        Ln2 = double(squeeze(Z(:, :, Ln2 ))) ./ 1914;
        [~, Ln3] = min(abs(i.wavelength - 1921));
        Ln3 = double(squeeze(Z(:, :, Ln3 ))) ./ 1921;
        [~, Ln4] = min(abs(i.wavelength - 1928));
        Ln4 = double(squeeze(Z(:, :, Ln4 ))) ./ 1928;
        [~, Ln5] = min(abs(i.wavelength - 1934));
        Ln5 = double(squeeze(Z(:, :, Ln5 ))) ./ 1934;
        [~, Ln6] = min(abs(i.wavelength - 1941));
        Ln6 = double(squeeze(Z(:, :, Ln6 ))) ./ 1941;
        Ln = (Ln1 + Ln2 + Ln3 + Ln4 + Ln5 + Ln6);

        [~, Ld1] = min(abs(i.wavelength - 1862));
        Ld1 = double(squeeze(Z(:, :, Ld1 ))) ./ 1862;
        [~, Ld2] = min(abs(i.wavelength - 1869));
        Ld2 = double(squeeze(Z(:, :, Ld2 ))) ./ 1869;
        [~, Ld3] = min(abs(i.wavelength - 1875));
        Ld3 = double(squeeze(Z(:, :, Ld3 ))) ./ 1875;
        [~, Ld4] = min(abs(i.wavelength - 2112));
        Ld4 = double(squeeze(Z(:, :, Ld4 ))) ./ 2112;
        [~, Ld5] = min(abs(i.wavelength - 2120));
        Ld5 = double(squeeze(Z(:, :, Ld5 ))) ./ 2120;
        [~, Ld6] = min(abs(i.wavelength - 2126));
        Ld6 = double(squeeze(Z(:, :, Ld6 ))) ./ 2126;
        Ld = (Ld1 + Ld2 + Ld3 + Ld4 + Ld5 +Ld6);
        
        Z25 = 1 - (Ln ./ Ld);
                
        Z25(Zremove > 0) = 0;
        Z25(Z25 < 0) = 0;
        Z25(Z25 > imageThresh) = 0;
        
        if strcmp(image, 'y')
                Zcontentsnew = zeros(r, c, 3);

                Zcontentsnew(:, :, 1) = Z25 * 2;

                figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));

                figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(Z25, 90))
                colormap('jet')
                caxis([0, max(max(Z25))])
                colorbar
        end

    end

% # 26 - BDI2000 :------------------------------------------------------ 26
%       Parameter: 2000 nanometer integrated band depth
%       Formulation: Divide reflectances from R1660 to R2390 by linear fit
%               from peak R (of 15) between 1300 and 1870 to R2530, then
%               integrate over (1- normalized radiances) to get band depth
%       Kernel Width: N/A
%       Rationale: Pyroxene
%       Caveats: Ices
%       Histogram bins:
%       Image threshold:
%       Notes:

%     if(SummProdNum ==  || SummProdNum == 00)
    
%         imageThresh = 0.;
%         imageT = 'Band Depth ';
%         heatmapT = 'Band Depth  heatmap';
%         hTitle = 'Band Depth  Parameter Histogram';
%         bLow = -0.0;
%         bHigh = 0.0;
%         pPlot = 'n';
%         pTitle = 'Band Depth  Parameter Pixel Plot';
%         Ls = 0;
%         Lc = 0;
%         Ll = 0;
%         Ks = 5;
%         Kc = 5;
%         Kl = 5;
%         
%         Z = BDP(BDP, image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);

% end

% # 27 - BD22100 :------------------------------------------------------ 27
%       Status: Significantly modified or new product
%       Parameter: 2100 nanometer shifted H2O band depth
%       Formulation: BDP
%       Kernel Width: 3-1930, 5-2132, 3-2250
%       Rationale: H2O in monohydrated sulfates
%       Caveats: Alunite, Serpentine
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 27 || SummProdNum == 200 || SummProdNum == 201)
         
        imageThresh = 0.3;
        imageT = 'Band Depth 27';
        heatmapT = 'Band Depth 27 heatmap';
        hTitle = 'Band Depth 27 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 27 Parameter Pixel Plot';
        Ls = 1930;
        Lc = 2132;
        Ll = 2250;
        Ks = 3;
        Kc = 5;
        Kl = 3;
        
        Z27 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 28 - BD2165 :------------------------------------------------------- 28
%       Status: Significantly modified or new product
%       Parameter: 2165 nanometer AI-OH band depth
%       Formulation: BDP
%       Kernel Width: 5-2120, 3-2165, 3-2230
%       Rationale: Pyrophyllite Kaolinite group
%       Caveats: Beidellite, Allophane, Imogolite
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 28 || SummProdNum == 200 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 28';
        heatmapT = 'Band Depth 28 heatmap';
        hTitle = 'Band Depth 28 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 28 Parameter Pixel Plot';
        Ls = 2120;
        Lc = 2165;
        Ll = 2230;
        Ks = 5;
        Kc = 3;
        Kl = 3;
        
        Z28 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 29 - BD2190 :------------------------------------------------------- 29
%       Status: Significantly modified or new product
%       Parameter: 2190 nanometer AI-OH band depth
%       Formulation: BDP
%       Kernel Width: 5-2120, 3-2185, 3-2250
%       Rationale: Beidellite, Allophane, Imogolite
%       Caveats: Kaolinite group
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 29 || SummProdNum == 200 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 29';
        heatmapT = 'Band Depth 29 heatmap';
        hTitle = 'Band Depth 29 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 29 Parameter Pixel Plot';
        Ls = 2120;
        Lc = 2185;
        Ll = 2250;
        Ks = 5;
        Kc = 3;
        Kl = 3;
        
        Z29 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 30 - MIN2200 :------------------------------------------------------ 30
%       Status: Significantly modified or new product
%       Parameter: 2160 nanometer Si-OH band depth and 2210 nanometer
%               H-bound Si-OH band depth (doublet)
%       Formulation: DBDP
%       Kernel Width: 5-2120, 3-2165, 3-2120, 5-2350
%       Rationale: Kaolinite group
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 30 || SummProdNum == 200)
    
        imageThresh = 0.3;
        imageT = 'Band Depth ';
        heatmapT = 'Band Depth 30 heatmap';
        hTitle = 'Band Depth 30 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 30 Parameter Pixel Plot';
        
        Ls = 2120;
        Lc = 2165;
        Ll = 2350;
        Ks = 5;
        Kc = 3;
        Kl = 5;
        
        Z30a = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
        
        Ls = 2120;
        Lc = 2210;
        Ll = 2350;
        Ks = 5;
        Kc = 3;
        Kl = 5;
        Z30b = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);

        Z30 = min( Z30a, Z30b);
                
        Z30(Zremove > 0) = 0;
        Z30(Z30 < 0) = 0;
        Z30(Z30 > imageThresh) = 0;
        
        if strcmp(image, 'y')
                Zcontentsnew = zeros(r, c, 3);

                Zcontentsnew(:, :, 1) = Z30 * 2;

                figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));

                figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(Z30, 90))
                colormap('jet')
                caxis([0, max(max(Z30))])
                colorbar
        end
        
        
    end

% # 31 - BD2210 :------------------------------------------------------- 31
%       Parameter: 2210 nanometer AI-OH band depth
%       Formulation: BDP
%       Kernel Width: 5-2165, 5-2210, 5-2250
%       Rationale: AI-OH minerals
%       Caveats: Gypsum, Alunite
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 31 || SummProdNum == 200 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 31';
        heatmapT = 'Band Depth 31 heatmap';
        hTitle = 'Band Depth 31 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 31 Parameter Pixel Plot';
        Ls = 2165;
        Lc = 2210;
        Ll = 2250;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z31 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 32 - D2200 :-------------------------------------------------------- 32
%       Status: Significantly modified or new product
%       Parameter: 2200 nanometer dropoff
%       Formulation:
%       Kernel Width: 7-1815, 5-2165, 7-2210, 7-2230, 7-2430
%       Rationale: AI-OH minerals
%       Caveats: Chlorite, Prehnite
%       Histogram bins:
%       Image threshold:
%       Notes:

 if(SummProdNum == 32 || SummProdNum == 200 || SummProdNum == 201)
    
        imageThresh = 0.3;
        imageT = 'Band Depth 32';
        heatmapT = 'Band Depth 32 heatmap';
        bLow = -0.3;
        bHigh = 0.3;
        
        [~, Ln1] = min(abs(i.wavelength - 2210));
        LnOne(:, :, 1) = double(squeeze(Z(:, :, Ln1 - 2 ))) ./ 2210;
        LnOne(:, :, 2) = double(squeeze(Z(:, :, (Ln1 - 1) ))) ./ 2210;
        LnOne(:, :, 3) = double(squeeze(Z(:, :, Ln1 ))) ./ 2210;
        LnOne(:, :, 4) = double(squeeze(Z(:, :, Ln1 + 1 ))) ./ 2210;
        LnOne(:, :, 5) = double(squeeze(Z(:, :, Ln1 + 2 ))) ./ 2210;
        Ln1 = mean(LnOne, 3);
        
        [~, Ln2] = min(abs(i.wavelength - 2230));
        LnTwo(:, :, 1) = double(squeeze(Z(:, :, Ln2 - 2 ))) ./ 2230;
        LnTwo(:, :, 2) = double(squeeze(Z(:, :, Ln2 - 1 ))) ./ 2230;
        LnTwo(:, :, 3) = double(squeeze(Z(:, :, Ln2 ))) ./ 2230;
        LnTwo(:, :, 4) = double(squeeze(Z(:, :, Ln2 + 1))) ./ 2230;
        LnTwo(:, :, 5) = double(squeeze(Z(:, :, Ln2 + 2 ))) ./ 2230;
        Ln2 = mean(LnTwo, 3);
        
        Ln = (Ln1 + Ln2);

        [~, Ld1] = min(abs(i.wavelength - 2165));
        LdOne(:, :, 1) = double(squeeze(Z(:, :, Ld1 - 2 ))) ./ 2165;
        LdOne(:, :, 2) = double(squeeze(Z(:, :, Ld1 - 1 ))) ./ 2165;
        LdOne(:, :, 3) = double(squeeze(Z(:, :, Ld1 ))) ./ 2165;
        LdOne(:, :, 4) = double(squeeze(Z(:, :, Ld1 + 1))) ./ 2165;
        LdOne(:, :, 5) = double(squeeze(Z(:, :, Ld1 + 2 ))) ./ 2165;
        Ld1 = mean(LdOne, 3);
        
        Ld = (2 * Ld1);
        
        Z32 = 1 - (Ln ./ Ld);
                
        Z32(Zremove > 0) = 0;
        Z32(Z32 < 0) = 0;
        Z32(Z32 > imageThresh) = 0;
        
        if strcmp(image, 'y')
                Zcontentsnew = zeros(r, c, 3);

                Zcontentsnew(:, :, 1) = Z32 * 2;

                figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));

                figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(Z32, 90))
                colormap('jet')
                caxis([0, max(max(Z32))])
                colorbar
        end

end


% # 33 - BD2230 :------------------------------------------------------- 33
%       Status: Significantly modified or new product
%       Parameter: 2230 nanometer band depth
%       Formulation: BDP
%       Kernel Width: 3-2210, 3-2235, 3-2252
%       Rationale: Hydroxylated ferric sulfate
%       Caveats: Other AI-OH minerals
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 33 || SummProdNum == 200)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 33';
        heatmapT = 'Band Depth 33 heatmap';
        hTitle = 'Band Depth 33 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 33 Parameter Pixel Plot';
        Ls = 2210;
        Lc = 2235;
        Ll = 2252;
        Ks = 3;
        Kc = 3;
        Kl = 3;
        
        Z33 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 34 - BD2250 :------------------------------------------------------- 34
%       Status: Significantly modified or new product
%       Parameter: 2250 nanometer broad AI-OH and Si-OH band depth
%       Formulation: BDP
%       Kernel Width: 5-2120, 7-2245, 3-2340
%       Rationale: Opal and other AI-OH minerals
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 34 || SummProdNum == 200 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 34';
        heatmapT = 'Band Depth 34 heatmap';
        hTitle = 'Band Depth 34 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 34 Parameter Pixel Plot';
        Ls = 2120;
        Lc = 2245;
        Ll = 2340;
        Ks = 5;
        Kc = 7;
        Kl = 3;
        
        Z34 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 35 - MIN2250 :------------------------------------------------------ 35
%       Status: Significantly modified or new product
%       Parameter: 2210 nanometer Si-OH band depth and 2260 nanometer
%               H-bound Si-OH band depth
%       Formulation:
%       Kernel Width: 5-2165, 3-2210, 3-2265, 5-2350
%       Rationale: Opal
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 35 || SummProdNum == 200 || SummProdNum == 201)
    
        imageThresh = 0.3;
        imageT = 'Band Depth ';
        heatmapT = 'Band Depth 35 heatmap';
        hTitle = 'Band Depth 35 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 35 Parameter Pixel Plot';
        
        Ls = 2165;
        Lc = 2210;
        Ll = 2350;
        Ks = 5;
        Kc = 3;
        Kl = 5;
        
        Z35a = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
        
        Ls = 2165;
        Lc = 2265;
        Ll = 2350;
        Ks = 5;
        Kc = 3;
        Kl = 5;
        Z35b = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);

        Z35 = min(Z35a, Z35b);
                
        Z35(Zremove > 0) = 0;
        Z35(Z35 < 0) = 0;
        Z35(Z35 > imageThresh) = 0;
            
        if (strcmp(image, 'y') && SummProdNum ~= 201)
                Zcontentsnew = zeros(r, c, 3);

                Zcontentsnew(:, :, 1) = Z35 * 2;

                figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));

                figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(Z35, 90))
                colormap('jet')
                caxis([0, max(max(Z35))])
                colorbar
        end
        
    end

% # 36 - BD2265 :------------------------------------------------------- 36
%       Status: Significantly modified or new product
%       Parameter: 2265 nanometer band depth
%       Formulation: BDP
%       Kernel Width: 5-2210, 3-2265, 5-2340
%       Rationale: Jarosite, Gibbsite, Acid-leached nontronite
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 36 || SummProdNum == 200)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 36';
        heatmapT = 'Band Depth 36 heatmap';
        hTitle = 'Band Depth 36 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 36 Parameter Pixel Plot';
        Ls = 2210;
        Lc = 2265;
        Ll = 2340;
        Ks = 5;
        Kc = 3;
        Kl = 5;
        
        Z36 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 37 - BD2290 :------------------------------------------------------- 37
%       Parameter: 2300 nanometer Mg, Fe-OH band depth/ 2292 nanometer CO2
%               ice band depth
%       Formulation: BDP
%       Kernel Width: 5-2250, 5-2290, 5-2350
%       Rationale: Mg, Fe-OH minerals, also CO2 ice
%       Caveats: Mg-Carbonate
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 37 || SummProdNum == 200 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 37';
        heatmapT = 'Band Depth 37 heatmap';
        hTitle = 'Band Depth 37 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 37 Parameter Pixel Plot';
        Ls = 2250;
        Lc = 2290;
        Ll = 2340;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z37 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 38 - D2300 :-------------------------------------------------------- 38
%       Parameter: 2300 nanometer dropoff
%       Formulation: 
%       Kernel Width: 5 for 1815, 2120, 2170, 2210, 2530
%                     3 for 2290, 2320, 2330
%       Rationale: Hydroxylated Fe, Mg silicates strongly >0
%       Caveats: Mg-Carbonate
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 38 || SummProdNum == 200 || SummProdNum == 201)
    
        imageThresh = 0.3;
        imageT = 'Band Depth 38';
        heatmapT = 'Band Depth 38 heatmap';
        bLow = -0.3;
        bHigh = 0.3;
         
        [~, Ln1] = min(abs(i.wavelength - 2290));        
        LnOne(:, :, 1) = double(squeeze(Z(:, :, (Ln1 - 1) ))) ./ 2290;
        LnOne(:, :, 2) = double(squeeze(Z(:, :, Ln1 ))) ./ 2290;
        LnOne(:, :, 3) = double(squeeze(Z(:, :, Ln1 + 1 ))) ./ 2290;
        Ln1 = mean(LnOne, 3);
        
        [~, Ln2] = min(abs(i.wavelength - 2320));
        LnTwo(:, :, 1) = double(squeeze(Z(:, :, (Ln2 - 1) ))) ./ 2320;
        LnTwo(:, :, 2) = double(squeeze(Z(:, :, Ln2 ))) ./ 2320;
        LnTwo(:, :, 3) = double(squeeze(Z(:, :, Ln2 + 1 ))) ./ 2320;
        Ln2 = mean(LnTwo, 3);
        
        [~, Ln3] = min(abs(i.wavelength - 2330));
        LnThree(:, :, 1) = double(squeeze(Z(:, :, (Ln3 - 1) ))) ./ 2330;
        LnThree(:, :, 2) = double(squeeze(Z(:, :, Ln3 ))) ./ 2330;
        LnThree(:, :, 3) = double(squeeze(Z(:, :, Ln3 + 1 ))) ./ 2330;
        Ln3 = mean(LnThree, 3);
        
        Ln = (Ln1 + Ln2 + Ln3);

        [~, Ld1] = min(abs(i.wavelength - 2120));
        LdOne(:, :, 1) = double(squeeze(Z(:, :, (Ld1 - 2) ))) ./ 2120;
        LdOne(:, :, 2) = double(squeeze(Z(:, :, (Ld1 - 1) ))) ./ 2120;
        LdOne(:, :, 3) = double(squeeze(Z(:, :, Ld1 ))) ./ 2120;
        LdOne(:, :, 4) = double(squeeze(Z(:, :, Ld1 + 1 ))) ./ 2120;
        LdOne(:, :, 5) = double(squeeze(Z(:, :, (Ld1 + 2) ))) ./ 2120;
        Ld1 = mean(LdOne, 3);
        
        [~, Ld2] = min(abs(i.wavelength - 2170));
        LdTwo(:, :, 1) = double(squeeze(Z(:, :, (Ld2 - 2) ))) ./ 2170;
        LdTwo(:, :, 2) = double(squeeze(Z(:, :, (Ld2 - 1) ))) ./ 2170;
        LdTwo(:, :, 3) = double(squeeze(Z(:, :, Ld2 ))) ./ 2170;
        LdTwo(:, :, 4) = double(squeeze(Z(:, :, Ld2 + 1 ))) ./ 2170;
        LdTwo(:, :, 5) = double(squeeze(Z(:, :, (Ld2 + 2) ))) ./ 2170;
        Ld2 = mean(LdTwo, 3);
                
        [~, Ld3] = min(abs(i.wavelength - 2210));
        LdThree(:, :, 1) = double(squeeze(Z(:, :, (Ld3 - 2) ))) ./ 2210;
        LdThree(:, :, 2) = double(squeeze(Z(:, :, (Ld3 - 1) ))) ./ 2210;
        LdThree(:, :, 3) = double(squeeze(Z(:, :, Ld3 ))) ./ 2210;
        LdThree(:, :, 4) = double(squeeze(Z(:, :, Ld3 + 1 ))) ./ 2210;
        LdThree(:, :, 5) = double(squeeze(Z(:, :, (Ld3 + 2) ))) ./ 2210;
        Ld3 = mean(LdThree, 3);    
        
        Ld = (Ld1 + Ld2 + Ld3);
        
        Z38 = 1 - (Ln ./ Ld);
        
        Z38(Zremove > 0) = 0;
        Z38(Z38 < 0) = 0;
        Z38(Z38 > imageThresh) = 0;
        
        if ( strcmp(image, 'y') && SummProdNum ~= 201 )
                Zcontentsnew = zeros(r, c, 3);

                Zcontentsnew(:, :, 1) = Z38 * 2;

                figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));

                figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(Z38, 90))
                colormap('jet')
                caxis([0, max(max(Z38))])
                colorbar
        end

    end

% # 39 - BD2355 :------------------------------------------------------- 39
%       Parameter: 2350 nanometer band depth
%       Formulation: BDP
%       Kernel Width: 5-2300, 5-2355, 5-2450
%       Rationale: Chlorite, Prehnite, Pumpellyite
%       Caveats: Carbonate, Serpentine
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 39 || SummProdNum == 200 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 39';
        heatmapT = 'Band Depth 39 heatmap';
        hTitle = 'Band Depth 39 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 39 Parameter Pixel Plot';
        Ls = 2300;
        Lc = 2355;
        Ll = 2450;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z39 = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 40 - SINDEX2 :------------------------------------------------------ 40
%       Status: Significantly modified or new product
%       Parameter: Inverse lever rule to detect convexity at 2290 nanometer
%               due to 2100 nanometer and 2400 nanometer absorptions
%       Formulation: IBDP
%       Kernel Width: 5-2120, 7-2290, 3-2400
%       Rationale: Hydrated sulfates (mono and polyhydrated sulfates) will
%               be strongly > 0
%       Caveats: Ices
%       Histogram bins:
%       Image threshold:
%       Notes:

     if(SummProdNum == 40 || SummProdNum == 200 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 40';
        heatmapT = 'Band Depth 40 heatmap';
        hTitle = 'Band Depth 40 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pTitle = 'Band Depth 40 Parameter Pixel Plot';
        Ls = 2120;
        Lc = 2290;
        Ll = 2400;
        Ks = 5;
        Kc = 7;
        Kl = 3;
        
        Z40 = BDP('IBDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);        

     end
     
% # 41 - ICER2 :-------------------------------------------------------- 41
%       Parameter: 2700 nanometer CO2 ice band
%       Formulation: 
%       Kernel Width: 5-2456, 5-2530, 5-2600
%       Rationale: CO2 versus water ice/soil; CO2 wil be strongly >0, water
%               ice will be <0
%       Caveats: N/A
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 42 - MIN2295-2480 :---------------------------------------------------------
%       Status: Significantly modified or new product
%       Parameter: Mg Carbonate overtone band depth and metal OH band
%       Formulation:
%       Kernel Width: 5 for 2165, 2295, 2364, 2480, 2570
%       Rationale: Mg carbonates; both overtones must be present
%       Caveats: Hydroxylated silicate + zeolite mixtures
%       Histogram bins:
%       Image threshold:
%       Notes:

%     if(SummProdNum == 42|| SummProdNum == 200)
%     
%         image = 'n';
%         imageThresh = 0.;
%         imageT = 'Band Depth 42';
%         heatmapT = 'Band Depth 42 heatmap';
%         histo = 'n';
%         hTitle = 'Band Depth 42 Parameter Histogram';
%         bLow = -0.0;
%         bHigh = 0.0;
%         pPlot = 'n';
%         pTitle = 'Band Depth 42 Parameter Pixel Plot';
%         
%         Ls = 2165;
%         Lc = 2295;
%         Ll = 2364;
%         Ks = 5;
%         Kc = 5;
%         Kl = 5;
%         
%         Z42a = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
% 
%         Ls = 2364;
%         Lc = 2480;
%         Ll = 2570;
%         Ks = 5;
%         Kc = 5;
%         Kl = 5;
%         
%         Z42b = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);
% 
%         Z42 = min(Z42a, Z42b);
%         
%     end

% # 43 -  :---------------------------------------------------------
%       Status: Significantly modified or new product
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 43 || SummProdNum == 200)
    
        imageThresh = 0.3;
        imageT = 'Band Depth 43';
        heatmapT = 'Band Depth 43 heatmap';
        histo = 'n';
        hTitle = 'Band Depth 43 Parameter Histogram';
        bLow = -0.3;
        bHigh = 0.3;
        pPlot = 'n';
        pTitle = 'Band Depth 43 Parameter Pixel Plot';
        
        Ls = 2250;
        Lc = 2345;
        Ll = 2430;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z43a = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);

        Ls = 2430;
        Lc = 2537;
        Ll = 2602;
        Ks = 5;
        Kc = 5;
        Kl = 5;
        
        Z43b = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);

        Z43 = min(Z43a, Z43b);
        
    end

% # 44 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 45 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 46 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 47 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 48 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 49 -  :---------------------------------------------------------
%       Status: Significantly modified or new product
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 50 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 51 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 52 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 53 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 54 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 54 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 54';
        heatmapT = 'Band Depth 54 heatmap';
        bLow = -0.3;
        bHigh = 0.3;
        
        [~, Ls] = min(abs(i.wavelength - 1080));
        S(:, :, 1) = double(squeeze(Z(:, :, (Ls - 2))));
        S(:, :, 2) = double(squeeze(Z(:, :, (Ls - 1))));
        S(:, :, 3) = double(squeeze(Z(:, :, Ls)));
        S(:, :, 4) = double(squeeze(Z(:, :, (Ls + 1))));
        S(:, :, 5) = double(squeeze(Z(:, :, (Ls + 2))));
        Z54 = median(S, 3);
        
        Z54(Zremove > 0) = 0;
        Z54(Z54 < 0) = 0;
        Z54(Z54 > imageThresh) = 0;
        
        if ( strcmp(image, 'y') && SummProdNum ~= 201 )
                Zcontentsnew = zeros(r, c, 3);

                Zcontentsnew(:, :, 1) = Z54 * 2;

                figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));

                figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(Z54, 90))
                colormap('jet')
                caxis([0, max(max(Z54))])
                colorbar
        end
         
    end

% # 55 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 55 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 55';
        heatmapT = 'Band Depth 55 heatmap';
        bLow = -0.3;
        bHigh = 0.3;
        
        [~, Ls] = min(abs(i.wavelength - 1506));
        S(:, :, 1) = double(squeeze(Z(:, :, (Ls - 2))));
        S(:, :, 2) = double(squeeze(Z(:, :, (Ls - 1))));
        S(:, :, 3) = double(squeeze(Z(:, :, Ls)));
        S(:, :, 4) = double(squeeze(Z(:, :, (Ls + 1))));
        S(:, :, 5) = double(squeeze(Z(:, :, (Ls + 2))));
        Z55 = median(S, 3);
        
        Z55(Zremove > 0) = 0;
        Z55(Z55 < 0) = 0;
        Z55(Z55 > imageThresh) = 0;
        
        if ( strcmp(image, 'y') && SummProdNum ~= 201 )
                Zcontentsnew = zeros(r, c, 3);

                Zcontentsnew(:, :, 1) = Z55 * 2;

                figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));

                figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(Z55, 90))
                colormap('jet')
                caxis([0, max(max(Z55))])
                colorbar
        end
         
    end

% # 56 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:

    if(SummProdNum == 56 || SummProdNum == 201)
        
        imageThresh = 0.3;
        imageT = 'Band Depth 56';
        heatmapT = 'Band Depth 56 heatmap';
        bLow = -0.3;
        bHigh = 0.3;
        
        [~, Ls] = min(abs(i.wavelength - 2529));
        S(:, :, 1) = double(squeeze(Z(:, :, (Ls - 2))));
        S(:, :, 2) = double(squeeze(Z(:, :, (Ls - 1))));
        S(:, :, 3) = double(squeeze(Z(:, :, Ls)));
        Z56 = median(S, 3);
        
        Z56(Zremove > 0) = 0;
        Z56(Z56 < 0) = 0;
        Z56(Z56 > imageThresh) = 0;
        
        if ( strcmp(image, 'y') && SummProdNum ~= 201 )
                Zcontentsnew = zeros(r, c, 3);

                Zcontentsnew(:, :, 1) = Z56 * 2;

                figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));

                figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
                imshow(imrotate(Z56, 90))
                colormap('jet')
                caxis([0, max(max(Z56))])
                colorbar
        end
        
        
    end

% # 57 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 58 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 59 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:
% # 60 -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:

% #  -  :---------------------------------------------------------
%       Parameter: 
%       Formulation:
%       Kernel Width:
%       Rationale:
%       Caveats:
%       Histogram bins:
%       Image threshold:
%       Notes:

%     if(SummProdNum ==  || SummProdNum == 00)
    
%         imageThresh = 0.;
%         imageT = 'Band Depth ';
%         heatmapT = 'Band Depth  heatmap';
%         histo = 'n';
%         hTitle = 'Band Depth  Parameter Histogram';
%         bLow = -0.0;
%         bHigh = 0.0;
%         pPlot = 'n';
%         pTitle = 'Band Depth  Parameter Pixel Plot';
%         Ls = 0;
%         Lc = 0;
%         Ll = 0;
%         Ks = 5;
%         Kc = 5;
%         Kl = 5;
%         
%         Z = BDP('BDP', image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i);

% end






% VNA - :-------------------------------------------------------------- VNA
%       From "VNIR albedo", shows photometrically corrected I/F at 770 nm and 
%       may be used to correlate spectral variations with morphology

    if(SummProdNum == 100 || SummProdNum == 101)
                 
      iTitle = ' ';
        
      Zvna = squeeze(Z(:, :, 228));
      Zvna(Zremove > 0) = 0;

      figure('Name', 'VNA heatmap', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
      imshow(imrotate(Zvna, 90))
      colormap('jet')
      caxis([0, max(max(Zvna))])
      colorbar
      
    end
    
% FEM / FM2 combined - :----------------------------------------- FEM / FM2
%       From "Fe minerals", shows info related to Fe minerals and represents the
%       curvature in the visible and near-infrared wavelengths related to iron.
%       FEM is particularly sensitive to ferric and ferrous mineral absorpions,
%       as well as negative slopes due to dust coatings or compacted dust
%       texture. Red colors indicate nanophase or crystalline ferric oxides,
%       green colors are usually a result of textural effects, and blue colors
%       suggest coarser-grained Fe minerals(particularly low-Ca pyroxene)

    if(SummProdNum == 100 || SummProdNum == 101)
                
        iTitle = ' ';
        
        ZcontentsnewFEM = zeros(r, c, 3);
        ZcontentsnewFEM(:, :, 1) = Z3 * 2;
        ZcontentsnewFEM(:, :, 2) = Z4 * 2;
        ZcontentsnewFEM(:, :, 3) = Z8 * 2;

        figure('Name', 'FEM', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        imshow(imrotate(imfuse(Zgray, ZcontentsnewFEM * 2, 'blend', 'Scaling', 'joint'), 90));
    
    end
    
%  FAL - :----------------------------------------- FAL
%     

    if(SummProdNum == 200 || SummProdNum == 201)
        
        iTitle = 'False color. An enhanced infrared false color representation of the scene. The wavelengths chosen highlight differences between key mineral group. Red/orange colors are usually characteristic of olivine-rich material, blue/green colors often indicate clay, green colors may indicate carbonate, and gray/brown colors often indicate basaltic material';
        
        ZcontentsnewFAL  = zeros(r, c, 3);
        ZcontentsnewFAL(:, :, 1) = Z56 * 2;
        ZcontentsnewFAL(:, :, 2) = Z55 * 2;
        ZcontentsnewFAL(:, :, 3) = Z54 * 2;

        figure('Name', 'FAL: False color', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        imshow(imrotate(imfuse(Zgray, ZcontentsnewFAL * 2, 'blend', 'Scaling', 'joint'), 90));
    
    end
    
%  MAF - :----------------------------------------- MAF
%     

    if(SummProdNum == 200 || SummProdNum == 201)
        
        iTitle = ' ';
                
        ZcontentsnewMAF  = zeros(r, c, 3);
        ZcontentsnewMAF(:, :, 1) = Z14 * 2;
        ZcontentsnewMAF(:, :, 2) = Z15 * 2;
        ZcontentsnewMAF(:, :, 3) = Z16 * 2;

        figure('Name', 'Mafic mineralogy', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        imshow(imrotate(imfuse(Zgray, ZcontentsnewMAF * 2, 'blend', 'Scaling', 'joint'), 90));
    
    end
    
%  HYD - :----------------------------------------- HYD
%     

    if(SummProdNum == 200 || SummProdNum == 201)
                
        iTitle = ' ';
        
        ZcontentsnewHYD  = zeros(r, c, 3);
        ZcontentsnewHYD(:, :, 1) = Z40 * 2;
        ZcontentsnewHYD(:, :, 2) = Z27 * 2;
        ZcontentsnewHYD(:, :, 3) = Z24 * 2;

        figure('Name', 'Hydrated mineralogy', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        imshow(imrotate(imfuse(Zgray, ZcontentsnewHYD * 2, 'blend', 'Scaling', 'joint'), 90));
    
    end
    
%  PHY - :----------------------------------------- PHY
%     

    if(SummProdNum == 200 || SummProdNum == 201)
                
        iTitle = ' ';
        
        ZcontentsnewPHY  = zeros(r, c, 3);
        ZcontentsnewPHY(:, :, 1) = Z38 * 2;
        ZcontentsnewPHY(:, :, 2) = Z32 * 2;
        ZcontentsnewPHY(:, :, 3) = Z25 * 2;

        figure('Name', 'Phyllosilicates', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        imshow(imrotate(imfuse(Zgray, ZcontentsnewPHY * 2, 'blend', 'Scaling', 'joint'), 90));
    
    end

% PFM - :----------------------------------------- PFM
%       

    if(SummProdNum == 200 || SummProdNum == 201)
                
        iTitle = ' ';
        
        ZcontentsnewPFM= zeros(r, c, 3);
        ZcontentsnewPFM(:, :, 1) = Z39 * 2;
        ZcontentsnewPFM(:, :, 2) = Z38 * 2;
        ZcontentsnewPFM(:, :, 3) = Z27 * 2;

        figure('Name', 'Phyllosilicates with Fe and Mg', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        imshow(imrotate(imfuse(Zgray, ZcontentsnewPFM * 2, 'blend', 'Scaling', 'joint'), 90));
    
    end    
    
    
% PAL  - :----------------------------------------- PAL
%       
    if(SummProdNum == 200 || SummProdNum == 201)
                
        iTitle = ' ';
        
        ZcontentsnewPAL  = zeros(r, c, 3);
        ZcontentsnewPAL(:, :, 1) = Z31 * 2;
        ZcontentsnewPAL(:, :, 2) = Z29 * 2;
        ZcontentsnewPAL(:, :, 3) = Z28 * 2;

        figure('Name', 'Phyllosilicates with AL', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        imshow(imrotate(imfuse(Zgray, ZcontentsnewPAL * 2, 'blend', 'Scaling', 'joint'), 90));
    
    end

% HYS - :----------------------------------------- HYS
%       

    if(SummProdNum == 200 || SummProdNum == 201)
                
        iTitle = ' ';
        
        ZcontentsnewHYS= zeros(r, c, 3);
        ZcontentsnewHYS(:, :, 1) = Z35 * 2;
        ZcontentsnewHYS(:, :, 2) = Z34 * 2;
        ZcontentsnewHYS(:, :, 3) = Z25 * 2;

        figure('Name', 'Hydrated silica', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        imshow(imrotate(imfuse(Zgray, ZcontentsnewHYS * 2, 'blend', 'Scaling', 'joint'), 90));
    
    end





% -------------------------------------------------------------------------
% Composites:
%     if(SummProdNum == 100)
% 
%         figure('Name', '3 and 8', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
%         ZcontentsnewFeBearing = zeros(975, 461, 3);        % uses 3 and 8
%         ZcontentsnewFeBearing(:, :, 1) = Z3 * 2;
%         ZcontentsnewFeBearing(:, :, 2) = Z8 * 2;
%         imshow(imrotate(imfuse(Zgray, ZcontentsnewFeBearing * 2, 'blend', 'Scaling', 'joint'), 90));
% 
%         figure('Name', '3, 4, 7', 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
%         ZcontentsnewHematite = zeros(975, 461, 3);         % uses 3, 4, 7
%         ZcontentsnewHematite(:, :, 1) = Z3 * 2;
%         ZcontentsnewHematite(:, :, 2) = Z4 * 2;
%         ZcontentsnewHematite(:, :, 3) = Z7 * 2;
%         imshow(imrotate(imfuse(Zgray, ZcontentsnewHematite * 2, 'blend', 'Scaling', 'joint'), 90));
% 
%     end
    
% -------------------------------------------------------------------------

% ZBDP function:

% imSeg = BDPbasedSegmentation( ZBDP );

% something = myDEMUD(ZBDP, k, nsel)





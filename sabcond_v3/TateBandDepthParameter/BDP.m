function Zout = BDP(bdp, image, imageThresh, imageT, heatmapT, Zremove, Zgray, histo, hTitle, bLow, bHigh, pPlot, pTitle, numToPlot, scrsz, Ls, Lc, Ll, Ks, Kc, Kl, Z, i)
% bdp       = type of band depth
% image     = if you want to produce images
% imageT    = image title
% heatmapT  = heatmap title
% Zremove   = mask
% Zgray     = grayscale image for base
% histo     = histogram option
% hTitle    = histogram title
% bLow      =   histogram bin low
% bHigh     =   histogram bin high
% Ls        = lambda shorter wave length
% Lc        = lambda center wave length
% Ll        = lambda longer wave length
% Ks        = kernel shorter length, usually 3 or 5
% Kc        = kernel center length, usually 3 or 5, 15 (BDP 13)
% Kl        = kernel longer length, usually 3 or 5
% Z         = input hyperspectral image
% i         = the wavelengths associated to each channel
% 

% S  - value of shorter wavelength ref
% C  - value of center wavelength ref
% L  - value of longer wavelength ref

 % [~, index] = min(abs(i.wavelength - waveLengthLooking))
 % closestValues = i.wavelength(index)
 
 [r, c, ~] = size(Zgray);

 [~, Ls] = min(abs(i.wavelength - Ls));
 [~, Lc] = min(abs(i.wavelength - Lc));
 [~, Ll] = min(abs(i.wavelength - Ll));

% S -----------------------------------------------------------------------
if(Ks == 5)
   S(:, :, 1) = double(squeeze(Z(:, :, (Ls - 2))));
   S(:, :, 2) = double(squeeze(Z(:, :, (Ls - 1))));
   S(:, :, 3) = double(squeeze(Z(:, :, Ls)));
   S(:, :, 4) = double(squeeze(Z(:, :, (Ls + 1))));
   S(:, :, 5) = double(squeeze(Z(:, :, (Ls + 2))));
   S = median(S, 3);
end

if(Ks == 3)
   S(:, :, 1) = double(squeeze(Z(:, :, (Ls - 1))));
   S(:, :, 2) = double(squeeze(Z(:, :, Ls)));
   S(:, :, 3) = double(squeeze(Z(:, :, (Ls + 1))));
   S = median(S, 3);
end

% C -----------------------------------------------------------------------
if(Kc == 7)
   C(:, :, 1) = double(squeeze(Z(:, :, (Lc - 3))));
   C(:, :, 2) = double(squeeze(Z(:, :, (Lc - 2))));
   C(:, :, 3) = double(squeeze(Z(:, :, (Lc - 1))));
   C(:, :, 4) = double(squeeze(Z(:, :, Lc)));
   C(:, :, 5) = double(squeeze(Z(:, :, (Lc + 1))));
   C(:, :, 6) = double(squeeze(Z(:, :, (Lc + 2))));
   C(:, :, 7) = double(squeeze(Z(:, :, (Lc - 3))));
   C = median(C, 3);
end

if(Kc == 5)
   C(:, :, 1) = double(squeeze(Z(:, :, (Lc - 2))));
   C(:, :, 2) = double(squeeze(Z(:, :, (Lc - 1))));
   C(:, :, 3) = double(squeeze(Z(:, :, Lc)));
   C(:, :, 4) = double(squeeze(Z(:, :, (Lc + 1))));
   C(:, :, 5) = double(squeeze(Z(:, :, (Lc + 2))));
   C = median(C, 3);
end

if(Kc == 3)
   C(:, :, 1) = double(squeeze(Z(:, :, (Lc - 1))));
   C(:, :, 2) = double(squeeze(Z(:, :, Lc)));
   C(:, :, 3) = double(squeeze(Z(:, :, (Lc + 1))));
   C = median(C, 3);
end

if(Kc == 1)
   C = double(squeeze(Z(:, :, Lc)));
end

% L -----------------------------------------------------------------------

if(Kl == 5)
   L(:, :, 1) = double(squeeze(Z(:, :, (Ll - 2))));
   L(:, :, 2) = double(squeeze(Z(:, :, (Ll - 1))));
   L(:, :, 3) = double(squeeze(Z(:, :, Ll)));
   L(:, :, 4) = double(squeeze(Z(:, :, (Ll + 1))));
   L(:, :, 5) = double(squeeze(Z(:, :, (Ll + 2))));
   L = median(L, 3);
end

if(Kl == 3)
   L(:, :, 1) = double(squeeze(Z(:, :, (Ll - 1))));
   L(:, :, 2) = double(squeeze(Z(:, :, Ll)));
   L(:, :, 3) = double(squeeze(Z(:, :, (Ll + 1))));
   L = median(L, 3);
end

% -------------------------------------------------------------------------

b = (i.wavelength(Lc) - i.wavelength(Ls)) ./ (i.wavelength(Ll) - i.wavelength(Ls));
a = 1 - b;

Rc = (a * S) + (b * L);

% -------------------------------------------------------------------------

if strcmp(bdp, 'BDP')           % BDP
    Zout = 1 - (C ./ Rc);
end

if strcmp(bdp, 'IBDP')          % IBDP 
    Zout = 1 - (Rc ./ C);
end

% Histogram ---------------------------------------------------------------

if strcmp(histo, 'y')
        figure('Name', hTitle, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        histogram(Zout(Zout ~= 0), 'binlimits', [bLow, bHigh])
        xlabel('band depth value');
        ylabel('count');
end

% Pixel Plot --------------------------------------------------------------

if strcmp(pPlot, 'y')
    
  [row, col] = find(Zout > 0 );    
  randPixs = randperm(length(row), numToPlot);

        figure('Name', pTitle, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
        for g = 1:numToPlot
            plot(i.wavelength, squeeze(Z(row(randPixs(g)), col(randPixs(g)), :)));
            hold on
        end
end

% Images --------------------------------------------------------------

if strcmp(image, 'y')
    
    Zcontentsnew = zeros(r, c, 3);
    Zout(Zremove > 0) = 0;
     
    Zout(Zout < 0) = 0;
    Zout(Zout > imageThresh) = 0;
        
    Zcontentsnew(:, :, 1) = Zout * 2;
    
    figure('Name', imageT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
    imshow(imrotate(imfuse(Zgray, Zcontentsnew * 2, 'blend', 'Scaling', 'joint'), 90));
        
    figure('Name', heatmapT, 'NumberTitle', 'off', 'Position', [1 scrsz(4) scrsz(3) scrsz(4)])
    imshow(imrotate(Zout, 90))
    colormap('jet')
    caxis([0, max(max(Zout))])
    colorbar
        
end

%  --------------------------------------------------------------
    
end
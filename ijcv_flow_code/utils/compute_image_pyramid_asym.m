function P = compute_image_pyramid_asym(img, nL, spacing, factor)
%%  
% COMPUTE_IMAGE_PYRAMID_ASYM computes nL level image pyramid of the input
% image IMG using filter. The spacing in the x and y direction can be
% different 

%   Author: Deqing Sun
%   Contact: dqsun@seas.harvard.edu
%   $Date: 2013- $
%   $Revision $

if nargin < 4
    factor = 2;
end
sigY = sqrt(spacing(1))/factor;
sigX = sqrt(spacing(2))/factor;

fX = fspecial('gaussian',[1 2*round(1.5*sigX)+1], sigX);
fY = fspecial('gaussian',[2*round(1.5*sigY)+1 1], sigY);

P   = cell(nL,1);
tmp = img;
P{1}= tmp;

% Get version information
%   From http://www.mathworks.com/matlabcentral/fileexchange/17285
v = sscanf (version, '%d.%d.%d') ; v = 10.^(0:-1:-(length(v)-1)) * v ;

for m = 2:nL    
    % Gaussian filtering 
    tmp = imfilter(tmp, fX, 'corr', 'symmetric', 'same');           
    tmp = imfilter(tmp, fY, 'corr', 'symmetric', 'same');           
    
    sz  = round([size(tmp,1)/spacing(1) size(tmp,2)/spacing(2)]);
    
    if min(sz) < 2
        break;
    end
    
    % IMRESIZE changes default algorithm since version 7.4 (R2007a)
    if v > 7.3
        tmp = imresize(tmp, sz, 'bilinear', 'Antialiasing', false);
    else
        % Disable antialiasing, old version for cluster
        tmp = imresize(tmp, sz, 'bilinear', 0); 
    end;
    
    if size(img, 4)>1
        tmp = reshape(tmp, [size(tmp,1), size(tmp,2), size(img,3), size(img,4)]);
    end;

    P{m} = tmp;
end;

	


	
	


function uvo = estimate_flow_demo(method, iSeq, seqName, varargin)
%ESTIMATE_FLOW_DEMO   Optical flow estimation demo program
%
% output UV is an M*N*2 matrix. UV(:,:,1) is the horizontal flow and
%   UV(:,:,2) is the vertical flow.
%
% Example
% -------
% uv = estimate_flow_demo; or estimate_flow_demo;
% reads the color RubberWhale sequence and uses default parameters and
% default method "Classic+NL-FastP" 
% 
% same as
% uv = estimate_flow_demo('classic+nl-fastp');
%
% uv = estimate_flow_demo('classic+nl-fastp', 4, 'middle-other');
%
% uv = estimate_flow_demo('classic+nl-fastp', 4, 'middle-other', 'lambda', 3, 'pyramid_levels', 5);
% takes user-defined parameters 
%
% Method can be
%   'classic+nl-fastp' (default)  'classic+nl' 'classic+nl-full'
%   'classic++'  'classic-c'  'classic-l'/'ba' 'hs'
%
% iSeq can ben 1 to 12: selects the sequence in the following cell arrays to process
% % training data
% SeqName = 'middle-other' 
%           {'Venus', 'Dimetrodon',   'Hydrangea',    'RubberWhale',...
%            'Grove2', 'Grove3', 'Urban2', 'Urban3', ...
%            'Walking', 'Beanbags',     'DogDance',     'MiniCooper'};
% % test data
% SeqName = 'middle-eval' 
%           {'Army',  'Mequon', 'Schefflera', 'Wooden',  'Grove', 'Urban', ...
%            'Yosemite',  'Teddy', 'Basketball',  'Evergreen',  'Backyard',  'Dumptruck'};
% 
% 'lambda'                trade-off (regularization) parameter; larger produces smoother flow fields 
% 'sigma_d'               parameter of the robust penalty function for the spatial term
% 'sigma_s'               parameter of the robust penalty function for the data term
% 'pyramid_levels'        pyramid levels for the quadratic formulation; default is automatic 
% 'pyramid_spacing'       downsampling ratio up each pyramid level for the quadratic formulation; default is 2
% 'gnc_pyramid_levels'    pyramid levels for the non-quadratic formulation; default is 2
% 'gnc_pyramid_spacing'   downsampling ratio up each pyramid level for the non-quadratic formulation; default is 1.25
%
%
% References:
% -----------
% Sun, D.; Roth, S. & Black, M. J. "Secrets of Optical Flow Estimation and
%   Their Principles" IEEE Int. Conf. on Comp. Vision & Pattern Recognition, 2010  
% 
% Sun, D.; Roth, S. & Black, M. J. "A Quantitative Analysis of Current
%   Practices in Optical Flow Estimation and The Principles Behind Them" 
%   Technical Report Brown-CS-10-03, 2010   
%
% Authors: Deqing Sun, Department of Computer Science, Brown University
% Contact: dqsun@cs.brown.edu
% $Date: $
% $Revision: $
%
% Copyright 2007-2010, Brown University, Providence, RI. USA
% 
%                          All Rights Reserved
% 
% All commercial use of this software, whether direct or indirect, is
% strictly prohibited including, without limitation, incorporation into in
% a commercial product, use in a commercial service, or production of other
% artifacts for commercial purposes.     
%
% Permission to use, copy, modify, and distribute this software and its
% documentation for research purposes is hereby granted without fee,
% provided that the above copyright notice appears in all copies and that
% both that copyright notice and this permission notice appear in
% supporting documentation, and that the name of the author and Brown
% University not be used in advertising or publicity pertaining to
% distribution of the software without specific, written prior permission.        
%
% For commercial uses contact the Technology Venture Office of Brown University
% 
% THE AUTHOR AND BROWN UNIVERSITY DISCLAIM ALL WARRANTIES WITH REGARD TO
% THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
% FITNESS FOR ANY PARTICULAR PURPOSE.  IN NO EVENT SHALL THE AUTHOR OR
% BROWN UNIVERSITY BE LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL
% DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
% PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
% ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
% THIS SOFTWARE.        

if (~isdeployed)
    addpath(genpath('utils'));
end

if nargin < 1
    method = 'classic+nl-fastp';
    iSeq   = 4;
    seqName = 'middle-other';
    %seqName = 'middle-eval';
elseif nargin == 1
    iSeq   = 4;
    seqName = 'middle-other';
end;
im1 = imread('D:\Work_LiyueGe\006_????????\0010_????\??????????????????\001_??????????\training\clean\temple_2\frame_0001.png');
im2 = imread('D:\Work_LiyueGe\006_????????\0010_????\??????????????????\001_??????????\training\clean\temple_2\frame_0002.png');
% images = [];
tmp1 = double(rgb2gray(uint8(im1)));
tmp2 = double(rgb2gray(uint8(im2)));
images  = cat(3, tmp1, tmp2);
uv =  readFlowFile('D:\Work_LiyueGe\006_????????\0010_????\??????????????????\001_??????????\training\flow\temple_2\frame_0001.flo');
[a,b,c] = partial_deriv(images, uv, 'bi-cubic');

% [im1, im2, tu, tv] = read_flow_file(seqName, iSeq);

% % test ROF per level for hand
% [im2, im1, tu, tv] = read_image_flow_tune_para(22,1);
% tu = -tu;
% tv = -tv;
% for i=0:20
%     if i<10
%         flow = readFlowFile(['D:\Work_LiyueGe\006_????????\003_??????\006_??????????\kitti\??????\00000',num2str(i),'_10.flo']);
%     else
%         flow = readFlowFile(['D:\Work_LiyueGe\006_????????\003_??????\006_??????????\kitti\??????\0000',num2str(i),'_10.flo']);
%     end
%     figure(1);
%     imshow(uint8(flowToColor(flow)));
%     if i<10
% %         imwrite(uint8(flowToColor(flow)),['D:\Work_LiyueGe\006_????????\003_??????\006_??????????\kitti\????\??????\00000',num2str(i),'_10.png']);
%     else
% %          imwrite(uint8(flowToColor(flow)),['D:\Work_LiyueGe\006_????????\003_??????\006_??????????\kitti\????\??????\0000',num2str(i),'_10.png']);
%     end
%     
% end
% uv = estimate_flow_interface(im1, im2, method, [], varargin);

% Display estimated flow fields
% figure; subplot(1,2,1);imshow(uint8(flowToColor(uv))); title('Middlebury color coding');
% subplot(1,2,2); plotflow(uv);   title('Vector plot');
% 
% if sum(~isnan(tu(:))) > 1
% 
%     [aae stdae aepe] = flowAngErr(tu, tv, uv(:,:,1), uv(:,:,2), 0); % ignore 0 boundary pixels
%     fprintf('\nAAE %3.3f average EPE %3.3f \n', aae, aepe);
%     
% end;

% Uncomment below and change FN to save the flow fields
% if ~exist(['result/' seqName], 'file');
%     mkdir(['result/' seqName]);
% end;
% fn  = sprintf('result/%s/estimated_flow_%03d.flo', seqName, iSeq);
% writeFlowFile(uv, fn);

% Uncomment below to read the save flow field
% uv = readFlowFile(fn);
% 
% if nargout == 1
%     uvo = uv;
% end;

% Uncomment below  to remove 'utils/' to your
%   matlab search path
% rmpath(genpath('utils'));
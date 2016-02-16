function [descp, pos] = uiuc_gbfeat(I, ndescriptors)

    % compute channels using oriented edge energy
    fbr = compute_channels_oe_nms(I);

    % rs are the radii for sample points
    rs =      [0 4 8 16];

    % nthetas are the number of samples at each radii
    nthetas = [1 8 8 10];

    % alpha is the rate of increase for blur
    alpha = 0.5;

    % beta is the base blur amount
    beta = 1;

    % Number of descriptors to extract per image
    if (nargin < 2)
        ndescriptors = 500;
    end
    
    % repulsion radius for rejection sampling
    rrep = 5;

    % Actually extract Geometric Blur descriptors for each image
    [descp, pos] = get_descriptors(fbr,ndescriptors,rrep,alpha,beta,rs,nthetas);
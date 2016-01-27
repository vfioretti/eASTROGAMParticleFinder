% Load events from simulator file, find particles tracks and save the results to a
% txt file.

close all
clear all
clc

addpath /home/astrogam/KALMAN-FILTER/MatlabParticleFinder/2D/Core

% Input file
in_fname = '/home/astrogam/G4_Projects/eASTROGAM/BoGEMMS-OUTPUT/eASTROGAMV1.0/Point/theta30/PixelRepli/ASTROMEV/MONO/100MeV/10000ph/onlyCAL/15keV/eAST201010101_CLUSTER_10000ph_Point_MONO_UNI_100MeV_30_225.dat';

%% Load

fprintf('Load data from %s\n', in_fname)

evtdb = evtload(in_fname);

%% Detector geometry

fprintf('Setup detector geometry\n')

% Number of planes
dtr.planes_no = 56;

% Definition of layers

% Detector layer Si 
dtr.layer(1).dz       = 0.05; % Thickness [cm]
dtr.layer(1).rl       = 9.37; % Radiation len. [cm], set to 0 to model vacuum 
dtr.layer(1).mip_mode = 1;    % Minimum ionizing particle mode, 0 no energy deposition, 1 use energy from file or MIP if no data is available, 2 use only MIP value
dtr.layer(1).mip      = 0;    % Minimum ionizing particle [MeV]

% Empty space
dtr.layer(2).dz       = 0.95;  % Thickness [cm]
dtr.layer(2).rl       = 0;    % Radiation len. [cm], set to NaN to model vacuum
dtr.layer(2).mip_mode = 0;    % Minimum ionizing particle mode, 0 no energy deposition, 1 use energy from file or MIP if no data is available, 2 use only MIP value
dtr.layer(2).mip      = 0;    % Minimum ionizing particle [MeV]

% Detector par. initialization
dtr = dtrparinit(dtr);

%% Tracker parameters

fprintf('Setup tracker\n')

% Particle finder default parameters
pfpar = pfindpar();

% Event planes selection
pfpar.plsrc.k = 5;    
pfpar.plsrc.m = 5;   
pfpar.plsrc.n = 5;    

% Track update probability
pfpar.trpar.alpha = NaN;    % 0 < value < 1 spec. the probability, set to NaN to use the min distance

% Track mainteninance

% Maximum deviation of the track direction wrt to the initial value
pfpar.trpar.thdev_init_mode = 0;   % 0 = no check, 1 = warning, 2 = check
pfpar.trpar.thdev_init_max  = 15;  % max deviation [deg]

% Maximum deviation of the track direction wrt to the previous value
pfpar.trpar.thdev_prev_mode = 0;   % 0 = no check, 1 = warning, 2 = check
pfpar.trpar.thdev_prev_max  = 5;   % max deviation [deg]

% Track duplication probability
pfpar.tfpar.alpha = NaN;     % 0 < value < 1 spec. the probability, set to NaN to use the min distance

% Particle track selection mode
pfpar.trk_sel_mode = 1;  % 0 = single track, 1 = double track

% Particle track reconstruction mode
pfpar.trk_rec_mode = 1;  % 0 = 2D, 1 = 3D

% Set verbose
pfpar.verbose = 1;

% Particle finder par. initialization
pfpar = pfindparinit(pfpar);

% Event energy [MeV]
e0 = 100;

%% Run processing

fprintf('\nProcessing\n')

pres = pfind(pfpar, dtr, evtdb, e0);

%% Save

% Build the file name form the input file
[fpath,fname,fext] = fileparts(in_fname);
out_fname = fullfile([fname '_PFIND_1_2' fext]);

fprintf('\nSave results in %s\n', out_fname)

fid = fopen(out_fname, 'w');

pfindprint(pres, 0, fid);

fclose(fid);




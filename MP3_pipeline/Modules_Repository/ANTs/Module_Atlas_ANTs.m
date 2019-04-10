function [files_in,files_out,opt] = Module_Atlas_ANTs(files_in,files_out,opt)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%% Initialize the module's parameters with default values 
if isempty(opt)

	%   % define every option needed to run this module
	% --> module_option(1,:) = field names
    % --> module_option(2,:) = defaults values
    module_option(:,1)   = {'script_location',  '/home/bouxf/Code/ANTs/antsbin/bin'};
    module_option(:,2)   = {'dimension',        '3'}; % TODO:remove my path
    module_option(:,3)   = {'transformation',   's'};
    module_option(:,4)   = {'atlas_filename',   'Atlas'};
    module_option(:,5)   = {'label_filename',   'Label'};
    module_option(:,6)   = {'mask_filename',    'Mask'};    
    
    module_option(:,7)   = {'RefInput',         1};
    module_option(:,8)   = {'InputToReshape',   1};
    module_option(:,9)   = {'Table_in',         table()};
    module_option(:,10)  = {'Table_out',        table()};
    module_option(:,11)  = {'OutputSequenceName','AllName'};
    module_option(:,12)  = {'output_filename_ext_atlas','Atlas'};
    module_option(:,13)  = {'output_filename_ext_label','Label'};
    
    opt.Module_settings  = psom_struct_defaults(struct(),module_option(1,:),module_option(2,:));
    
    
    %% list of everything displayed to the user associated to their 'type'
    % --> user_parameter(1,:) = user_parameter_list
    % --> user_parameter(2,:) = user_parameter_type
    % --> user_parameter(3,:) = parameter_default
    % --> user_parameter(4,:) = psom_parameter_list
    % --> user_parameter(5,:) = Scans_input_DOF : Degrees of Freedom for the user to choose the scan
    % --> user_parameter(6,:) = IsInputMandatoryOrOptional : If none, the input is set as Optional.
    % --> user_parameter(7,:) = Help : text data which describe the parameter (it
    % will be display to help the user)
    user_parameter(:,1)   = {'Description','Text','','','','',...
        {
        'ANTs Atlas Matching:'
        '    ANTS was created by:'
        '    Brian B. Avants, Nick Tustison and Gang Song'
        '    Penn Image Computing And Science Laboratory'
        '    University of Pennsylvania'
        '    https://github.com/ANTsX/ANTs'
        ''
        'Prerequisite: Put your ''.nii'' atlas in the ''data/atlas'' folder'
        }'};
    
    user_parameter(:,2)   = {'Select one anatomical scan as input','1Scan','','',{'SequenceName'}, 'Mandatory',''};
    user_parameter(:,3)   = {'Parameters','','','','', '', ''};
    user_parameter(:,4)   = {'   .ANTs script location','char','','script_location','', '',...
        {'The ''bin'' ANTs path (.../antsbin/bin)'}};
    
    s               = split(mfilename('fullpath'),'MP3_pipeline',1);
    folder_files	= dir(fullfile(s{1}, 'data/atlas/'));
    if isempty(folder_files)
        folder_files(1).name = ' ';
    end
    user_parameter(:,5)   = {'   .Atlas filename','cell', {folder_files.name}, 'atlas_filename','','',...
        {'Select your atlas file'}};
    user_parameter(:,6)   = {'   .Label filename','cell', {folder_files.name}, 'label_filename','','',...
        {'Select your atlas labels file'}};
    user_parameter(:,7)   = {'   .Dimension','cell', {'2','3'},'dimension','', '',...
        {'2 or 3 (for 2 or 3 dimensional registration of single volume)'}};
    user_parameter(:,8)   = {'   .Transformation','cell', {'t','r','a','s','sr','so','b','br','bo'},'transformation','','',... 
        {'Choose the transform type (default = ''s''):'
        '    t: translation (1 stage)'
        '    r: rigid (1 stage)'
        '    a: rigid + affine (2 stages)'
        '    s: rigid + affine + deformable syn (3 stages)'
        '    sr: rigid + deformable syn (2 stages)'
        '    so: deformable syn only (1 stage)'
        '    b: rigid + affine + deformable b-spline syn (3 stages)'
        '    br: rigid + deformable b-spline syn (2 stages)'
        '    bo: deformable b-spline syn only (1 stage)'}};    
    user_parameter(:,9)   = {'   .Mask ROI','1ROI', '', '', {'SequenceName'}, 'Optional',...
        {'Select ROI (optional)'}};
    
    VariableNames = {'Names_Display', 'Type', 'Default', 'PSOM_Fields', 'Scans_Input_DOF', 'IsInputMandatoryOrOptional','Help'};
    opt.table = table(user_parameter(1,:)', user_parameter(2,:)', user_parameter(3,:)', user_parameter(4,:)', user_parameter(5,:)', user_parameter(6,:)', user_parameter(7,:)','VariableNames', VariableNames);
    %%
    
    % So for no input file is selected and therefore no output
    % The output file will be generated automatically when the input file
    % will be selected by the user
    files_in.In1 = {''};
    files_out.In1 = {''};
    return
    
end
%%%%%%%%


if isempty(files_out)
    opt.Table_out = opt.Table_in(opt.RefInput,:);
    opt.Table_out.IsRaw = categorical(0);   
    opt.Table_out.Path = categorical(cellstr([opt.folder_out, filesep]));
    if strcmp(opt.OutputSequenceName, 'AllName')
        opt.Table_out.SequenceName = categorical(cellstr(opt.output_filename_ext_atlas));
    elseif strcmp(opt.OutputSequenceName, 'Extension')
        opt.Table_out.SequenceName = categorical(cellstr([char(opt.Table_out.SequenceName), opt.output_filename_ext]));
    end
    opt.Table_out.Filename = categorical(cellstr([char(opt.Table_out.Patient), '_', char(opt.Table_out.Tp), '_', char(opt.Table_out.SequenceName)]));
    f_out = [char(opt.Table_out.Path), char(opt.Table_out.Patient), '_', char(opt.Table_out.Tp), '_', char(opt.Table_out.SequenceName), '.nii'];
    files_out.In1{1} = f_out;
    
    opt2 = opt;
    if strcmp(opt2.OutputSequenceName, 'AllName')
        opt2.Table_out.SequenceName = categorical(cellstr(opt2.output_filename_ext_label));
    elseif strcmp(opt2.OutputSequenceName, 'Extension')
        opt2.Table_out.SequenceName = categorical(cellstr([char(opt2.Table_out.SequenceName), opt2.output_filename_ext]));
    end
    opt2.Table_out.Filename = categorical(cellstr([char(opt2.Table_out.Patient), '_', char(opt2.Table_out.Tp), '_', char(opt2.Table_out.SequenceName)]));
    f_out = [char(opt2.Table_out.Path), char(opt2.Table_out.Patient), '_', char(opt2.Table_out.Tp), '_', char(opt2.Table_out.SequenceName), '.nii'];
    files_out.In2{1} = f_out;
    
    opt.Table_out = [opt.Table_out; opt2.Table_out];
end




%% Syntax
if ~exist('files_in','var')||~exist('files_out','var')||~exist('opt','var')
    error('Smoothing:brick','Bad syntax, type ''help %s'' for more info.',mfilename)
end

%% If the test flag is true, stop here !

if opt.flag_test == 1
    return
end
[Status, Message, Wrong_File] = Check_files(files_in);
if ~Status
    error('Problem with the input file : %s \n%s', Wrong_File, Message)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s = split(mfilename('fullpath'),'MP3_pipeline',1);
s = s{1};

prefix = char(opt.Table_in(1,:).Filename);

% Execute the ANTs command line
%compute transformations
if any(contains(fields(files_in), 'In2')) %if a mask is given
    system(['bash ' s 'MP3_pipeline/Modules_Repository/ANTs/ANTs/sync_atlas.sh' ...
            ' -s ' opt.script_location ...
            ' -a ' s 'data/atlas/' opt.atlas_filename ...
            ' -i ' files_in.In1{1} ...    
            ' -d ' opt.dimension ...
            ' -t ' opt.transformation ...
            ' -o ' s 'data/atlas/' prefix '_transformation_' ...
            ' -x ' files_in.In2{1} ...
            ]);
else
    system(['bash ' s 'MP3_pipeline/Modules_Repository/ANTs/ANTs/sync_atlas.sh' ...
            ' -s ' opt.script_location ...
            ' -a ' s 'data/atlas/' opt.atlas_filename ...
            ' -i ' files_in.In1{1} ...    
            ' -d ' opt.dimension ...
            ' -t ' opt.transformation ...
            ' -o ' s 'data/atlas/' prefix '_transformation_' ...
            ]);
end

transf0 = dir([s 'data/atlas/' prefix '_transformation_0*']);
transf1 = dir([s 'data/atlas/' prefix '_transformation_Inverse*']);


%rescale atlas map
system(['bash ' s 'MP3_pipeline/Modules_Repository/ANTs/ANTs/apply_transformation.sh' ...
        ' -s ' opt.script_location ...
        ' -d ' opt.dimension ...
        ' -t ' '"' transf0.folder '/' transf1.name ' [' transf0.folder '/' transf0.name ',1]' '"'  ...
        ' -i ' files_in.In1{1} ...
        ' -l ' s 'data/atlas/' opt.atlas_filename ...
        ' -o ' files_out.In1{1} ...
        ' -v ' '0'
        ]);

% Json processing
[path, name, ~] = fileparts(files_in.In1{1});
jsonfile = [path, '/', name, '.json'];
J = ReadJson(jsonfile);

J = KeepModuleHistory(J, struct('files_in', files_in, 'files_out', files_out, 'opt', opt, 'ExecutionDate', datestr(datetime('now'))), mfilename); 

[path, name, ~] = fileparts(files_out.In1{1});
jsonfile = [path, '/', name, '.json'];
WriteJson(J, jsonfile)


%rescale label map
system(['bash ' s 'MP3_pipeline/Modules_Repository/ANTs/ANTs/apply_transformation.sh' ...
        ' -s ' opt.script_location ...
        ' -d ' opt.dimension ...
        ' -t ' '"' transf0.folder '/' transf1.name ' [' transf0.folder '/' transf0.name ',1]' '"'  ...
        ' -i ' files_in.In1{1} ...
        ' -l ' s './data/atlas/' opt.label_filename ...
        ' -o ' files_out.In2{1} ...
        ' -v ' '0'
        ]);
    
% Json processing
[path, name, ~] = fileparts(files_in.In1{1});
jsonfile = [path, '/', name, '.json'];
J = ReadJson(jsonfile);

J = KeepModuleHistory(J, struct('files_in', files_in, 'files_out', files_out, 'opt', opt, 'ExecutionDate', datestr(datetime('now'))), mfilename); 

[path, name, ~] = fileparts(files_out.In2{1});
jsonfile = [path, '/', name, '.json'];
WriteJson(J, jsonfile)


% remove temp files
temp_files = dir([s './data/atlas/' prefix '_transformation_*']);
for i =1:size(temp_files)
    delete(temp_files(i).name);
end











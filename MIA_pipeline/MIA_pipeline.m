function varargout = MIA_pipeline(varargin)
% MIA_PIPELINE MATLAB code for MIA_pipeline.fig
%      MIA_PIPELINE, by itself, creates a new MIA_PIPELINE or raises the existing
%      singleton*.
%
%      H = MIA_PIPELINE returns the handle to a new MIA_PIPELINE or the handle to
%      the existing singleton*.
%
%      MIA_PIPELINE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MIA_PIPELINE.M with the given input arguments.
%
%      MIA_PIPELINE('Property','Value',...) creates a new MIA_PIPELINE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MIA_pipeline_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MIA_pipeline_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MIA_pipeline

% Last Modified by GUIDE v2.5 15-Jan-2018 15:49:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MIA_pipeline_OpeningFcn, ...
                   'gui_OutputFcn',  @MIA_pipeline_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before MIA_pipeline is made visible.
function MIA_pipeline_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MIA_pipeline (see VARARGIN)

% Choose default command line output for MIA_pipeline
handles.output = hObject;

handles.MIA_data = varargin{3};
handles.Modules_listing = {'Relaxometry', '   .T1map (Multi Inversion Time)', '   .T1map (Multi Angles)', '   .T2map', '   .T2*map',...
                '   .deltaR2', '   .deltaR2*',...
    'Perfusion', '   .Blood volume fraction (steady-state)', '   .Dynamic Susceptibility Contrast', '   .Vessel Size Imaging (steady-state)', ...
                '   .Vessel Densisty (steady-state)', '   .Cerebral blood flow (ASL)',  '   .Cerebral blood flow (ASL-Dynamic)',...
     'Permeability', '   .Dynamic Contrast Enhancement (Phenomenology)', '   .Dynamic Contrast Enhancement (Quantitative)',...          
     'Oxygenation', '   .R2prim', '   .SO2map', '   .CMRO2',...
     'MRFingerprint', '   .Vascular MRFingerprint'...
     'SPM', '   .SPM: Coreg', '   .SPM: Reslice','   .SPM: Realign', ...
     };
 handles.Module_groups = {'Relaxometry','Perfusion', 'Permeability', 'Oxygenation', 'MRFingerprint', 'SPM' };
 
 
 handles.Tags_listing = handles.MIA_data.database.Properties.VariableNames;
 
%  
%  {'Arithmetic', 'Mean slices', 'Smooth', 'Add slices', ...
%    'SPM: Realign (Over time)', 'Same registration as', 'Normalization', 'Repair outlier',...
%     'Remove images', 'Shift images', 'Import Atlas (and ROI)','Export to Nifti'};
%     'T2starcorr3D', 'ASL_InvEff',

set(handles.MIA_pipeline_module_listbox, 'String', handles.Modules_listing);
set(handles.MIA_pipeline_add_tag_popupmenu, 'String', handles.Tags_listing);
set(handles.MIA_pipeline_remove_tag_popupmenu, 'String', {'NoMoreTags'})
handles.Source_selected = handles.Tags_listing{1};
handles.Remove_Tags_listing = {'NoMoreTags'};
handles.Remove_selected = handles.Remove_Tags_listing{1};
MIA_pipeline_add_tag_popupmenu_Callback(hObject, eventdata, handles)
handles.MIA_pipeline_Filtering_Table.Data = [];
handles.MIA_pipeline_Filtering_Table.ColumnName = {};
% Update handles structure
guidata(hObject, handles);




% UIWAIT makes MIA_pipeline wait for user response (see UIRESUME)
% uiwait(handles.MIA_pipeline_creator_GUI);


% --- Outputs from this function are returned to the command line.
function varargout = MIA_pipeline_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in MIA_pipeline_add_module_button.
function MIA_pipeline_add_module_button_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_add_module_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
module_selected = get(handles.MIA_pipeline_module_popupmenu,'Value');
module_list = get(handles.MIA_pipeline_module_popupmenu,'String');
if isfield(handles, 'biograph_fig')
    if ~isempty(findobj('Tag', 'BioGraphTool'))
        close(handles.biograph_fig);
    end
    handles = rmfield(handles, 'biograph_fig');
    handles = rmfield(handles, 'biograph_obj');
end
if isfield(handles, 'pipeline')
    if sum(strcmp(fieldnames(handles.pipeline), char(module_list(module_selected))))
        module_nbr = strfind(fieldnames(handles.pipeline), char(module_list(module_selected)));
        module_nbr = sum([module_nbr{:}]);
        module_name = [char(module_list(module_selected)), '_' num2str(module_nbr+1)];
        eval(['handles.pipeline.' module_name '= handles.new_module;']);      
    else
        eval(['handles.pipeline.' char(module_list(module_selected)) '= handles.new_module;']);
    end
else
    eval(['handles.pipeline.' char(module_list(module_selected)) '= handles.new_module;']);
    
end

% for i = 1:size(handles.new_module.files_in,1)
%     files_in.(['subject' num2str(i)]).file1 = handles.new_module.files_in(i,:);
% end
% pipeline = struct();
% % Get the list of subjects from files_in
% list_subject = fieldnames(files_in);
% 
% opt.folder_out = '/test/';
% 
% % [files_in,files_out,opt] = brick_name(files_in,opt.folder_out,opt);
% 
% % Loop over subjects
% for num_s = 1:length(list_subject)
%     % Plug the ?fmri? input files of the subjects in the job
%     job_in = files_in.(list_subject{num_s,:}).file1;
%     % Use the default output name
%     job_out = '';
%     % Force a specific folder organization for outputs
%     opt.test_brick.folder_out = [opt.folder_out list_subject{num_s} filesep];
%     % Give a name to the jobs
%     job_name = ['test_brick_' list_subject{num_s}];
%     % The name of the employed brick
%     brick = 'test_brick';
%     % Add the job to the pipeline
%     pipeline = psom_add_job(pipeline, job_name,brick,job_in,job_out,opt.test_brick);
%     % The outputs of this brick are just
%     % intermediate outputs :biograph_obj
%     % clean these up as soon as possible
% %     pipeline = psom_add_clean(pipeline, [job_name ...
% %         '_clean'],pipeline.(job_name).files_out);
% end

% display the pipeline
handles.biograph_obj = psom_visu_dependencies(handles.pipeline);
set(0, 'ShowHiddenHandles', 'on')
handles.biograph_fig = gcf;
set(handles.biograph_fig, 'Name', 'MIA pipeline creator');
guidata(hObject, handles);





% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.MIA_pipeline_creator_GUI)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.MIA_pipeline_creator_GUI,'Name') '?'],...
                     ['Close ' get(handles.MIA_pipeline_creator_GUI,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.MIA_pipeline_creator_GUI)



% --- Executes on selection change in MIA_pipeline_module_parameters.
function MIA_pipeline_module_parameters_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_module_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MIA_pipeline_module_parameters contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MIA_pipeline_module_parameters


parameter_selected = get(handles.MIA_pipeline_module_parameters,'Value');

switch handles.new_module.opt.parameter_type{parameter_selected}
    case 'Scan'
        if handles.Source_selected == 'Database'
            SequenceType_listing = unique(handles.MIA_data.database.SequenceName(handles.MIA_data.database.Type == 'Scan'));
            table.data(1:numel(SequenceType_listing),1) = cellstr(SequenceType_listing);
            table.data(1:numel(SequenceType_listing),2) = {false};
            table.columnName = {'Scan Type', 'Select Input'};
            table.editable = [false true];
            table.Database = handles.MIA_data.database;
        else % case of selecting input data from an output module
            
            
        end
    case 'char'
        table.data(1:numel(SequenceType_listing),1) = cellstr(SequenceType_listing);
        table.data(1:numel(SequenceType_listing),2) = {false};
        table.columnName = {'Scan Type', 'Select Input'};
        
        
        
        table.editable = [false true];
    otherwise
        table.data = '';
        table.columnName = '';
        table.editable = false;
end

%% update the setup table
% set names of the columns
set(handles.MIA_pipeline_parameter_setup_table, 'ColumnName', table.columnName);
% set data (default's parameters)
set(handles.MIA_pipeline_parameter_setup_table, 'Data', table.data);
% set each colomn editable
set(handles.MIA_pipeline_parameter_setup_table, 'columnEditable',  table.editable );
if ~isempty(table.data)
    % set ColumnWidth to auto

    merge_Data = [table.columnName; table.data];
    dataSize = size(merge_Data);
    % Create an array to store the max length of data for each column
    maxLen = zeros(1,dataSize(2));
    % Find out the max length of data for each column
    % Iterate over each column
    for i=1:dataSize(2)
        % Iterate over each row
        for j=1:dataSize(1)
            len = length(merge_Data{j,i});
            % Store in maxLen only if its the data is of max length
            if(len > maxLen(1,i))
                maxLen(1,i) = len;
            end
        end
    end
    % Some calibration needed as ColumnWidth is in pixels
    cellMaxLen = num2cell(maxLen*6);
    % Set ColumnWidth of UITABLE
    set(handles.MIA_pipeline_parameter_setup_table, 'ColumnWidth', cellMaxLen);
    
end










% parameter_selected = get(handles.MIA_pipeline_module_parameters,'Value');
% parameter_list = get(handles.MIA_pipeline_module_parameters,'String');
% set(handles.MIA_pipeline_parameter_setup, 'Value', 1);
% table_is_present = 0;
% % sub parameter --> find the ascending name
% if strfind(char(parameter_list(parameter_selected)), '  .')
%     for i=parameter_selected-1:-1:1
%         if isempty(strfind(char(parameter_list(i)), '  .'))
%             set(handles.MIA_pipeline_parameter_setup, 'String', eval(['handles.new_module.', char(parameter_list(i)), strrep(char(parameter_list(parameter_selected)), '  .', '.')]));
%             return
%         end
%     end
% elseif  ~isstruct(eval(['handles.new_module.', char(parameter_list(parameter_selected))]))
%     if strcmp(char(parameter_list(parameter_selected)), 'files_in')
%         table_is_present = 1;     
%         set(handles.MIA_pipeline_parameter_setup, 'String', handles.new_module.files_in)
%     elseif strcmp(char(parameter_list(parameter_selected)), 'files_out')
%         output_extention = handles.new_module.SequenceName;
%         handles.new_module.files_out = generate_file_name(handles, handles.new_module.files_in_index,  output_extention);
%         set(handles.MIA_pipeline_parameter_setup, 'String', handles.new_module.files_out)
%     else
%         set(handles.MIA_pipeline_parameter_setup, 'String', eval(['handles.new_module.',char(parameter_list(parameter_selected))]));
%     end
% else
%     set(handles.MIA_pipeline_parameter_setup, 'String', '');
% end
% if isfield(handles.new_module, 'files_in_filter_data') && table_is_present
%     % set names of the columns
%     set(handles.MIA_pipeline_parameter_setup_table, 'ColumnName', handles.new_module.files_in_filter_name);
%     % set data (default's parameters)
%     set(handles.MIA_pipeline_parameter_setup_table, 'Data', handles.new_module.files_in_filter_data);
%     % set columnFormat (option for each parameters)
%     set(handles.MIA_pipeline_parameter_setup_table, 'columnFormat', handles.new_module.files_in_filter_format);
%     % set ColumnWidth to auto
%     width= num2cell(max(cellfun(@length,[handles.new_module.files_in_filter_data(1,:)' handles.new_module.files_in_filter_name']')).*7);
%     set(handles.MIA_pipeline_parameter_setup_table,'ColumnWidth',width)
%     % set each colomn editable
%     set(handles.MIA_pipeline_parameter_setup_table, 'columnEditable', logical(handles.new_module.files_in_filter_editable));
%     
% else
%     set(handles.MIA_pipeline_parameter_setup_table, 'Data', '');
%     set(handles.MIA_pipeline_parameter_setup_table, 'ColumnName', '');
% 
% end


guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function MIA_pipeline_module_parameters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_module_parameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function update_setting_windows(hObject, eventdata, handles)




% --- Executes on selection change in MIA_pipeline_parameter_setup.
function MIA_pipeline_parameter_setup_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_parameter_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MIA_pipeline_parameter_setup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MIA_pipeline_parameter_setup



% --- Executes during object creation, after setting all properties.
function MIA_pipeline_parameter_setup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_parameter_setup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MIA_pipeline_clear_modules_button.
function MIA_pipeline_clear_modules_button_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_clear_modules_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'pipeline')
    handles = rmfield(handles, 'pipeline');
    if ~isempty(findobj('Tag', 'BioGraphTool'))
        close(handles.biograph_fig);
    end
    handles = rmfield(handles, 'biograph_fig');
    handles = rmfield(handles, 'biograph_obj');
end
guidata(hObject, handles);
function edge_callbacks(hObject, eventdata, handles)
eventdata = [];
handles = guidata(findobj('Tag', 'MIA_pipeline_creator_GUI'));
module_list = get(handles.MIA_pipeline_module_popupmenu, 'String');
get(hObject, 'ID')
% sub_module = strfind(hObject.ID, '_');
% if ~isempty(sub_module)
%     module_name = hObject.ID(1:sub_module-1);
% else
%     module_name =hObject.ID;
% end
% idx = find(ismember(module_list, module_name));
% set(handles.MIA_pipeline_module_popupmenu, 'Value', idx)


function node_callbacks(hObject, eventdata, handles)
eventdata = [];
handles = guidata(findobj('Tag', 'MIA_pipeline_creator_GUI'));
module_list = get(handles.MIA_pipeline_module_popupmenu, 'String');

sub_module = strfind(hObject.ID, '_');
if ~isempty(sub_module)
    module_name = hObject.ID(1:sub_module-1);
else
    module_name =hObject.ID;
end
idx = find(ismember(module_list, module_name));
set(handles.MIA_pipeline_module_popupmenu, 'Value', idx)

%% test delete node
% handles.pipeline = rmfield(handles.pipeline, (char(hObject.ID)));
% update_setting_windows(hObject, eventdata, handles)
% if ~isempty(findobj('Tag', 'BioGraphTool'))
%     close(handles.biograph_fig);
% end
% handles = rmfield(handles, 'biograph_fig');
% handles = rmfield(handles, 'biograph_obj');
% handles.biograph_obj = psom_visu_dependencies(handles.pipeline);
% set(0, 'ShowHiddenHandles', 'on')
% handles.biograph_fig = gcf;
% set(handles.biograph_fig, 'Name', 'MIA pipeline creator');
% guidata(findobj('Tag', 'MIA_pipeline_creator_GUI'), handles);

%%%%
handles.new_module = handles.pipeline.(char(hObject.ID));
update_setting_windows(hObject, eventdata, handles)


% switch node.ID
% case 'Node 1'
%     disp('Hello, I''m node 1');
% case 'Node 2'
%     disp('What''s up? This is node 2');
% case 'Node 3'
%     disp('Hi! You''ve clicked node 3');
% case 'Node 4'
%     disp('I''m node 4 and I don''t want to talk!');
% case 'Node 5'
%     disp('Who dares bother node 5??');
% end


% --- Executes when entered data in editable cell(s) in MIA_pipeline_parameter_setup_table.
function MIA_pipeline_parameter_setup_table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_parameter_setup_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

table_data = get(handles.MIA_pipeline_parameter_setup_table, 'Data');
patient_listing = table_data(:,1);
patient_selected = patient_listing(find([table_data{:,2}]' == true));

% % case go back to all patient
% if table_data{1,2} == 1 && handles.new_module.files_in_filter_data{1,2} == 0
%     idex_patient = true(numel(handles.MIA_data.database.Patient),1);
%     table_data(1,2) = {true};
%     table_data(2:numel(unique(handles.MIA_data.database.Patient))+1,2) = {false};
%     % from all patient to a specific patient
% elseif sum(find([table_data{:,2}]' == true)) >1 && table_data{1,2} == 1
%     table_data{1,2} = false;
%     patient_selected = patient_listing(find([table_data{:,2}]' == true));
%     idex_patient = handles.MIA_data.database.Patient == patient_selected;
%     
%     % if all patient is selected
% elseif sum(find([table_data{:,2}]' == true))  == 1 && table_data{1,2} == 1
%     idex_patient = true(numel(handles.MIA_data.database.Patient),1);
%     % 1 or more patient (but not all)
% else
%     idex_patient = false(numel(handles.MIA_data.database.Patient),1);
%     for i=1:numel(patient_selected)
%         idex_patient = idex_patient | handles.MIA_data.database.Patient == patient_selected(i);
%     end
% end
% 
% tp_listing = table_data(:,3);
% tp_selected = tp_listing(find([table_data{:,4}]' == true));
% 
% % case go back to all time point
% if table_data{1,4} == 1 && handles.new_module.files_in_filter_data{1,4} == 0
%     idex_tp = true(numel(handles.MIA_data.database.Tp),1);
%     table_data(1,4) = {true};
%     table_data(2:numel(unique(handles.MIA_data.database.Tp))+1,4) = {false};
%     % from all time point to a specific time point
% elseif sum(find([table_data{:,4}]' == true)) >1 && table_data{1,4} == 1
%     table_data{1,4} = false;
%     tp_selected = tp_listing(find([table_data{:,4}]' == true));
%     idex_tp = handles.MIA_data.database.Tp == tp_selected;
%     
%     % if all time point is selected
% elseif sum(find([table_data{:,4}]' == true))  == 1 && table_data{1,4} == 1
%     idex_tp = true(numel(handles.MIA_data.database.Tp),1);
%     % if 1 or more time point (but not all)
% else
%     idex_tp = false(numel(handles.MIA_data.database.Tp),1);
%     for i=1:numel(tp_selected)
%         idex_tp = idex_tp | handles.MIA_data.database.Tp == tp_selected(i);
%     end
% end
% 
% SequenceName_listing =table_data(:,5);
% SequenceName_selected = SequenceName_listing(find([table_data{:,6}]' == true));
% if isempty(SequenceName_selected)
%     index_SequenceName =true(numel(handles.MIA_data.database.Tp,1));
% else
%      index_SequenceName = false(numel(handles.MIA_data.database.Tp),1);
%     for i=1:numel(SequenceName_selected)
%         index_SequenceName = index_SequenceName | handles.MIA_data.database.SequenceName == SequenceName_selected(i);
%     end
% end
% handles.new_module.files_in = char(handles.MIA_data.database.Filename(idex_patient & idex_tp & index_SequenceName));
% handles.new_module.files_in_index = find(idex_patient & idex_tp & index_SequenceName);
% handles.new_module.files_in_filter_data = table_data;

guidata(hObject, handles);
MIA_pipeline_module_parameters_Callback(hObject, eventdata, handles)
  %             handles.new_module.files_in_filter_name = {'Patient Name', '', 'Time Point','', 'Sequence Name',''};
        %             Patient_listing = unique(handles.MIA_data.database.Patient);
        %             Tp_listing = unique(handles.MIA_data.database.Tp);
        %             SequenceName_listing = unique(handles.MIA_data.database.SequenceName);
        %             handles.new_module.files_in_filter_data = {'all', false, 'all', false, char(SequenceName_listing(1)),false};
        %             handles.new_module.files_in_filter_data(1:numel(Patient_listing)+1,1) = ['all' cellstr(Patient_listing)'];
        %             handles.new_module.files_in_filter_data(1,2) = {true};
        %             handles.new_module.files_in_filter_data(2:numel(Patient_listing),2) = {false};
        %
        %             handles.new_module.files_in_filter_data(1:numel(Tp_listing)+1,3) = ['all' cellstr(Tp_listing)'];
        %             handles.new_module.files_in_filter_data(1,4) = {true};
        %             handles.new_module.files_in_filter_data(2:numel(Patient_listing),4) = {false};
        %
        %             handles.new_module.files_in_filter_data(1:numel(SequenceName_listing),5) = cellstr(SequenceName_listing)';
        %             handles.new_module.files_in_filter_data(1:numel(SequenceName_listing),6) = {false};
        %
        %             handles.new_module.files_in_filter_format = {'char', 'logical','char', 'logical','char', 'logical' };
        %             handles.new_module.files_in_filter_editable = [0 1 0 1 0 1];
        %
        %             set(handles.MIA_pipeline_parameter_setup,  'String', cellstr(handles.MIA_data.database.nii));

function output_file_names = generate_file_name(handles, database_indexes, output_extention)

output_file_names = [...
    char(handles.MIA_data.database.Patient(database_indexes)) ...
    repmat('-', [numel(database_indexes),1])...
    char(handles.MIA_data.database.Tp(database_indexes))...
    repmat('-', [numel(database_indexes),1])...
    repmat(output_extention, [numel(database_indexes),1])...
    repmat('_', [numel(database_indexes),1])...
    repmat(datestr(now,'yyyymmdd-HHMMSSFFF'), [numel(database_indexes),1])...
    repmat('.nii', [numel(database_indexes),1])
    ] ;
output_file_names  = strrep(cellstr(output_file_names), ' ', '');


% --- Executes on selection change in MIA_pipeline_add_tag_popupmenu.
function MIA_pipeline_add_tag_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_add_tag_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Source_selected = handles.MIA_pipeline_add_tag_popupmenu.String{handles.MIA_pipeline_add_tag_popupmenu.Value};
TagValues = [{'all'} ; cellstr(char(unique(handles.MIA_data.database{:,handles.Source_selected})))];

handles.MIA_pipeline_Unique_Values_Tag.Data = TagValues;
handles.MIA_pipeline_Unique_Values_Tag.ColumnName = {handles.Source_selected};

guidata(hObject, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns MIA_pipeline_add_tag_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MIA_pipeline_add_tag_popupmenu


% --- Executes during object creation, after setting all properties.
function MIA_pipeline_add_tag_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_add_tag_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');

end

function nii_json_fullfilename = fullfilename(handles, nii_index, ext)

nii_json_fullfilename = [char(handles.MIA_data.database.Path(nii_index)) char(handles.MIA_data.database.Filename(nii_index)) ext];


% --- Executes on selection change in MIA_pipeline_module_listbox.
function MIA_pipeline_module_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_module_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MIA_pipeline_module_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MIA_pipeline_module_listbox


% set(handles.MIA_pipeline_parameter_setup, 'Value', 1);
% set(handles.MIA_pipeline_module_parameters, 'Value', 1);
module_selected = get(handles.MIA_pipeline_module_listbox, 'Value');
if isfield(handles, 'new_module')
    handles = rmfield(handles, 'new_module');
end

ismodule = 0;
switch char(handles.Modules_listing(module_selected))
%     {'Relaxometry', '   .T1map (Multi Inversion Time)', '   .T1map (Multi Angles)', '   .T2map', '   .T2*map',...
%                 '   .deltaR2', '   .deltaR2*',...
%     'Perfusion', '   .Blood volume fraction (steady-state)', '   .Vessel Size Imaging (steady-state)', ...
%                 '   .Vessel Densisty (steady-state)', '   .Cerebral blood flow (ASL)',  '   .Cerebral blood flow (ASL-Dynamic)',...
%      'Permeability', '   .Dynamic Contrast Enhancement (Phenomenology)', '   .Dynamic Contrast Enhancement (Quantitative)',...          
%      'Oxygenation', '   .R2prim', '   .SO2map', '   .CMRO2',...
%      'MRFingerprint', '   .Vascular MRFingerprint'...
%      'SPM', '   .SPM: Coreg', '   .SPM: Realign&Coreg', '   .SPM: Reslice','   .SPM: Realign', ...
%      };
    case handles.Module_groups	
        module_parameters_string = [char(handles.Modules_listing(module_selected)) ' modules'];
    case '   .SPM: Coreg'
        [handles.new_module.files_in ,handles.new_module.files_out ,handles.new_module.opt] = Module_SPMCoreg('',  '', '');
        handles.new_module.command = '[files_in,files_out,opt] = module_SPMCoreg(char(handles.new_module.files_in),handles.new_module.files_out,handles.new_module.opt)';
        handles.new_module.module_name = 'module_SPMCoreg';
        module_parameters_string = handles.new_module.opt.parameter_list;
        ismodule = 1;
    case '   .T2map'
        [handles.new_module.files_in ,handles.new_module.files_out ,handles.new_module.opt] = Module_T2map('',  '', '');
        handles.new_module.command = '[files_in,files_out,opt] = module_T2map(char(handles.new_module.files_in),handles.new_module.files_out,handles.new_module.opt)';
        handles.new_module.module_name = 'module_T2map';
        module_parameters_string = handles.new_module.opt.parameter_list;
        ismodule = 1;
        
        %         parameter_list = {'files_in', 'files_out', 'parameters', '  .DSC_parameter1', '  .DSC_parameter2'};
        
%         
%         handles.new_module.command = 'T2_module(files_in,files_out,parameter)';
%         handles.new_module.files_in_index = 1:size(handles.MIA_data.database.Patient);
%         handles.new_module.files_in = cellstr(handles.MIA_data.database.Filename);
%         handles.new_module.files_in_filter_name = {'Patient Name', '', 'Time Point','', 'Sequence Name',''};
%         Patient_listing = unique(handles.MIA_data.database.Patient);
%         Tp_listing = unique(handles.MIA_data.database.Tp);
%         SequenceName_listing = unique(handles.MIA_data.database.SequenceName);
%         handles.new_module.files_in_filter_data = {'all', false, 'all', false, char(SequenceName_listing(1)),false};
%         handles.new_module.files_in_filter_data(1:numel(Patient_listing)+1,1) = ['all' cellstr(Patient_listing)'];
%         handles.new_module.files_in_filter_data(1,2) = {true};
%         handles.new_module.files_in_filter_data(2:numel(Patient_listing)+1,2) = {false};
%         
%         handles.new_module.files_in_filter_data(1:numel(Tp_listing)+1,3) = ['all' cellstr(Tp_listing)'];
%         handles.new_module.files_in_filter_data(1,4) = {true};
%         handles.new_module.files_in_filter_data(2:numel(Patient_listing)+1,4) = {false};
%         
%         handles.new_module.files_in_filter_data(1:numel(SequenceName_listing),5) = cellstr(SequenceName_listing)';
%         handles.new_module.files_in_filter_data(1:numel(SequenceName_listing),6) = {false};
%         
%         handles.new_module.files_in_filter_format = {'char', 'logical','char', 'logical','char', 'logical' };
%         handles.new_module.files_in_filter_editable = [0 1 0 1 0 1];
%         
%         handles.new_module.SequenceName = 'T2map';
%         handles.new_module.files_out = generate_file_name(handles, handles.new_module.files_in_index,  handles.new_module.SequenceName);
%         handles.new_module.opt.threshold = 5;
%         handles.new_module.opt.flag_test =1;
%         parameter_list ={'files_in', 'files_out', 'parameters', '  .threshold'};
        
    otherwise
        module_parameters_string = 'Not Implemented yet!!';     
end
set(handles.MIA_pipeline_module_parameters, 'String', module_parameters_string);

if ismodule
    MIA_pipeline_module_parameters_Callback(hObject, eventdata, handles)
else
    table.data = '';
    table.columnName = '';
    table.editable = false;
    
    %% update the setup table
    % set names of the columns
    set(handles.MIA_pipeline_parameter_setup_table, 'ColumnName', table.columnName);
    % set data (default's parameters)
    set(handles.MIA_pipeline_parameter_setup_table, 'Data', table.data);
    % set each colomn editable
    set(handles.MIA_pipeline_parameter_setup_table, 'columnEditable',  table.editable );
end
   

%% save the data
guidata(findobj('Tag', 'MIA_pipeline_creator_GUI'), handles);






% --- Executes during object creation, after setting all properties.
function MIA_pipeline_module_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_module_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in MIA_pipeline_exectute_module_button.
function MIA_pipeline_exectute_module_button_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_exectute_module_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MIA_pipeline_close_modules_button.
function MIA_pipeline_close_modules_button_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_close_modules_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MIA_pipeline_Add_Tag_Button.
function MIA_pipeline_Add_Tag_Button_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_Add_Tag_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(intersect(handles.Source_selected, handles.MIA_pipeline_Filtering_Table.ColumnName))
    NewTagValues = [{'all'} ; cellstr(char(unique(handles.MIA_data.database{:,handles.Source_selected})))];
    SizeVert = max(size(NewTagValues,1), size(handles.MIA_pipeline_Filtering_Table.Data,1));
    SizeHor = size(handles.MIA_pipeline_Filtering_Table.Data,2)+1;
    FullTable = cell(SizeVert,SizeHor);
    FullTable(1:size(handles.MIA_pipeline_Filtering_Table.Data,1),1:size(handles.MIA_pipeline_Filtering_Table.Data,2)) = handles.MIA_pipeline_Filtering_Table.Data;
    FullTable(1:size(NewTagValues,1),size(handles.MIA_pipeline_Filtering_Table.Data,2)+1) = NewTagValues;
    handles.MIA_pipeline_Filtering_Table.Data = FullTable;
    handles.MIA_pipeline_Filtering_Table.ColumnName = [handles.MIA_pipeline_Filtering_Table.ColumnName; {handles.Source_selected}];
else
    msgbox('This Tag is already used ! You cannot use it twice.', 'Warning')
end
Tag_To_Add = handles.Source_selected;
Index = find(contains(handles.Tags_listing, Tag_To_Add));
NewTagListing = {handles.Tags_listing{1:Index-1},handles.Tags_listing{Index+1:end}};
if isempty(NewTagListing)
    set(handles.MIA_pipeline_add_tag_popupmenu, 'String', {'NoMoreTags'})
    set(handles.MIA_pipeline_add_tag_popupmenu, 'Value', 1);
    handles.Source_selected = {'NoMoreTags'};
    handles.Tags_listing = {'NoMoreTags'};
else
    set(handles.MIA_pipeline_add_tag_popupmenu, 'String', NewTagListing);
    set(handles.MIA_pipeline_add_tag_popupmenu, 'Value', 1);
    handles.Source_selected = NewTagListing{1};
    handles.Tags_listing = NewTagListing;
    MIA_pipeline_add_tag_popupmenu_Callback(hObject, eventdata, handles)
end
if contains(handles.MIA_pipeline_remove_tag_popupmenu.String, 'NoMoreTag')
    set(handles.MIA_pipeline_remove_tag_popupmenu,'String', Tag_To_Add);
    handles.Remove_selected = Tag_To_Add;
else
%handles.Remove_Tag_Listing = {handles.Remove_Tag_Listing, Tag_To_Add};
    if size(handles.MIA_pipeline_remove_tag_popupmenu.String,1)==1
        set(handles.MIA_pipeline_remove_tag_popupmenu,'String',{handles.MIA_pipeline_remove_tag_popupmenu.String; Tag_To_Add});
        handles.Remove_Tags_listing = handles.MIA_pipeline_remove_tag_popupmenu.String;
    else
        set(handles.MIA_pipeline_remove_tag_popupmenu,'String',[handles.MIA_pipeline_remove_tag_popupmenu.String; Tag_To_Add]);
        handles.Remove_Tags_listing = handles.MIA_pipeline_remove_tag_popupmenu.String;
    end
end
guidata(hObject, handles);

% --- Executes on button press in MIA_pipeline_Remove_Tag_Button.
function MIA_pipeline_Remove_Tag_Button_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_Remove_Tag_Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(intersect(handles.Remove_selected, handles.MIA_pipeline_Filtering_Table.ColumnName))
    msgbox('This Tag is not used ! You cannot remove it.', 'Warning')
else
   Index = find(contains(handles.MIA_pipeline_Filtering_Table.ColumnName, handles.Remove_selected));
   handles.MIA_pipeline_Filtering_Table.Data(:,Index) = [];
   [val, index]=min(sum(cellfun(@isempty,handles.MIA_pipeline_Filtering_Table.Data)));
   handles.MIA_pipeline_Filtering_Table.Data = handles.MIA_pipeline_Filtering_Table.Data(~cellfun(@isempty, handles.MIA_pipeline_Filtering_Table.Data(:,index)), :);
   %handles.MIA_pipeline_Filtering_Table.Data = handles.MIA_pipeline_Filtering_Table.Data(~cellfun('isempty',handles.MIA_pipeline_Filtering_Table.Data));
   handles.MIA_pipeline_Filtering_Table.ColumnName(Index) = [];
end
Tag_To_Add = handles.Remove_selected;
Index = find(contains(handles.Remove_Tags_listing, Tag_To_Add));
NewTagListing = {handles.Remove_Tags_listing{1:Index-1},handles.Remove_Tags_listing{Index+1:end}};
if isempty(NewTagListing)
    set(handles.MIA_pipeline_remove_tag_popupmenu, 'String', {'NoMoreTags'})
    set(handles.MIA_pipeline_remove_tag_popupmenu, 'Value', 1);
    handles.Remove_selected = {'NoMoreTags'};
    handles.Remove_Tags_listing = {'NoMoreTags'};
else
    set(handles.MIA_pipeline_remove_tag_popupmenu, 'String', NewTagListing);
    set(handles.MIA_pipeline_remove_tag_popupmenu, 'Value', 1);
    handles.Remove_selected = NewTagListing{1};
    handles.Remove_Tags_listing = NewTagListing;
    MIA_pipeline_remove_tag_popupmenu_Callback(hObject, eventdata, handles)
end
if contains(handles.MIA_pipeline_add_tag_popupmenu.String, 'NoMoreTag')
    set(handles.MIA_pipeline_add_tag_popupmenu,'String', Tag_To_Add);
else
%handles.Remove_Tag_Listing = {handles.Remove_Tag_Listing, Tag_To_Add};
    if size(handles.MIA_pipeline_add_tag_popupmenu.String,1)==1
        set(handles.MIA_pipeline_add_tag_popupmenu,'String',{handles.MIA_pipeline_add_tag_popupmenu.String; Tag_To_Add});
        handles.Tags_listing = handles.MIA_pipeline_add_tag_popupmenu.String;
    else
        set(handles.MIA_pipeline_add_tag_popupmenu,'String',[handles.MIA_pipeline_add_tag_popupmenu.String; Tag_To_Add]);
        handles.Tags_listing = handles.MIA_pipeline_add_tag_popupmenu.String;
    end
end
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in MIA_pipeline_Filtering_Table.
function MIA_pipeline_Filtering_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_Filtering_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
NbSelected = length(eventdata.Indices);
for i = 1:NbSelected
    NameSelected = eventdata.Source.Data{eventdata.Indices(i,1), eventdata.Indices(i,2)};
    Tag = handles.MIA_pipeline_Filtering_Table.ColumnName{enventdata.Indices(i,2)};
end

guidata(hObject, handles);


% --- Executes on button press in MIA_pipeline_pushMIASelection.
function MIA_pipeline_pushMIASelection_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_pushMIASelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in MIA_pipeline_remove_tag_popupmenu.
function MIA_pipeline_remove_tag_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_remove_tag_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.Remove_selected = handles.MIA_pipeline_remove_tag_popupmenu.String{handles.MIA_pipeline_remove_tag_popupmenu.Value};
guidata(hObject, handles);

% Hints: contents = cellstr(get(hObject,'String')) returns MIA_pipeline_remove_tag_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MIA_pipeline_remove_tag_popupmenu



% --- Executes on button press in MIA_pipeline_pushMIATPSelection.
function MIA_pipeline_pushMIATPSelection_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_pushMIATPSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in MIA_pipeline_push_Database.
function MIA_pipeline_push_Database_Callback(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_push_Database (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function MIA_pipeline_remove_tag_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MIA_pipeline_remove_tag_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

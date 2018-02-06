function data_selected = finddata_selected(handles)


patient_seleted = get(handles.MIA_name_list, 'String');
patient_seleted = patient_seleted(get(handles.MIA_name_list, 'Value'),:);
time_point_seleted = get(handles.MIA_time_points_list, 'String');
time_point_seleted = time_point_seleted(get(handles.MIA_time_points_list, 'Value'),:);
scan_seleted = get(handles.MIA_scans_list, 'String');
scan_seleted= scan_seleted(get(handles.MIA_scans_list, 'Value'),:);

data_selected = nan(size(patient_seleted,1) + size(time_point_seleted,1) +size(scan_seleted,1) - 2,1);
ii=1;
for i = 1:size(patient_seleted,1)
    for j= 1:size(time_point_seleted,1)
        for z = 1:size(scan_seleted,1)
            data_selected(ii) = find(handles.database.Patient == patient_seleted(i,:) &...
                handles.database.Tp == time_point_seleted(j,:) &...
                handles.database.SequenceName == scan_seleted(z,:));
            ii=ii+1;
        end
    end    
end

% id_listing = unique(handles.database.Patient);
% 
% Patient_filter = handles.database.Patient== id_listing(patient_seleted);
% 
% tp_listing = unique(handles.database.Tp(Patient_filter));
% % set(handles.MIA_time_points_list, 'String', string(tp_listing));
% tp_filter = handles.database.Tp== tp_listing(time_point_seleted);
% 
% if get(handles.MIA_scan_VOIs_button, 'Value') == 0  % search inside the scan listing
%     is_scan =  handles.database.Type == 'Scan';
%     nii_listing = handles.database.SequenceName(Patient_filter & tp_filter & is_scan);
%     
% else % search inside the ROI listing
%     is_ROI =  handles.database.Type == 'ROI';
%     nii_listing = handles.database.SequenceName(Patient_filter & tp_filter & is_ROI);
% end
% 
% for i=1:numel(nii_listing(scan_seleted))
%     sequence_filter =  handles.database.SequenceName== nii_listing(scan_seleted(i));
%     data_selected(i) = find(Patient_filter & tp_filter & sequence_filter == 1);
%     
% end


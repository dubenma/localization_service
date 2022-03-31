%% plot model without ceiling
model = pcread(fullfile(params.dataset.models.dir, 'livinglab_2', 'cloud.ply'));
model = model.Location(1:30:end,:);
filter_z = model(:,3) < 2.5;
model = model(filter_z,:);
pcshow(model); 

%% plot colored XYZcut
load(this_db_matname, 'XYZcut');
load(this_db_matname, 'RGBcut');
hold on; 
pcshow(reshape(XYZcut, [],3), reshape(RGBcut, [],3));


%% show 3 nearby
% figure()
query_id = 14;
nearby_id = [24,21,26];

dir = '/local/localization_service/Maps/SPRING/Broca_dataset2';
load(fullfile(dir, 'queries', 'livinglab_2', 'poses', string(query_id+1), sprintf('cutout_pano_%d_-120_0.jpg.mat', query_id)))
load(fullfile(dir, 'queries', 'livinglab_2', 'matfiles', string(query_id+1), sprintf('cutout_pano_%d_-120_0.jpg.mat', query_id)))
hold on; pcshow(reshape(XYZcut, [],3), reshape(RGBcut, [],3));
ax_x = [position', position' + R * [2,0,0]'];
ax_y = [position', position' + R * [0,2,0]'];
ax_z = [position', position' + R * [0,0,2]'];
hold on;
plot3(ax_x(1,:), ax_x(2,:), ax_x(3,:),'r', 'LineWidth', 3)
plot3(ax_y(1,:), ax_y(2,:), ax_y(3,:),'g', 'LineWidth', 3)
plot3(ax_z(1,:), ax_z(2,:), ax_z(3,:),'b', 'LineWidth', 3)

for i = 1:length(nearby_id)
    load(fullfile(params.dataset.dir, 'poses', 'livinglab_2', string(nearby_id(i)+1), sprintf('cutout_pano_%d_-90_180.jpg.mat', nearby_id(i))))
    load(fullfile(params.dataset.dir, 'matfiles', 'livinglab_2', string(nearby_id(i)+1), sprintf('cutout_pano_%d_-90_180.jpg.mat', nearby_id(i))))
    hold on; pcshow(reshape(XYZcut, [],3), reshape(RGBcut, [],3));
    ax_x = [position', position' + R * [2,0,0]'];
    ax_y = [position', position' + R * [0,2,0]'];
    ax_z = [position', position' + R * [0,0,2]'];
    hold on;
    plot3(ax_x(1,:), ax_x(2,:), ax_x(3,:),'r', 'LineWidth', 3)
    plot3(ax_y(1,:), ax_y(2,:), ax_y(3,:),'g', 'LineWidth', 3)
    plot3(ax_z(1,:), ax_z(2,:), ax_z(3,:),'b', 'LineWidth', 3)
end


%% show Standa's
figure()
query_id = 8;
nearby_id = [9,30,27];

dir = '/local/localization_service/Maps/SPRING/Broca_dataset';

query_name = sprintf('cutout_%d_90_0.jpg.mat', query_id);
load(fullfile(dir, 'queries', 'livinglab_2', 'poses', string(query_id), query_name))
load(fullfile(dir, 'queries', 'livinglab_2', 'matfiles', string(query_id), query_name))

hold on; pcshow(reshape(XYZcut, [],3), reshape(RGBcut, [],3));
Rfix = [1 0 0; 0 -1 0; 0 0 -1];

ax_x = [position', position' + R * [2,0,0]'];
ax_y = [position', position' + R * [0,2,0]'];
ax_z = [position', position' + R * [0,0,2]'];
hold on;
plot3(ax_x(1,:), ax_x(2,:), ax_x(3,:),'r', 'LineWidth', 3)
plot3(ax_y(1,:), ax_y(2,:), ax_y(3,:),'g', 'LineWidth', 3)
plot3(ax_z(1,:), ax_z(2,:), ax_z(3,:),'b', 'LineWidth', 3)

% for i = 1:length(nearby_id)
%     db_name = sprintf('cutout_pano_%d_-90_0.jpg.mat', nearby_id(i));
%     load(fullfile(params.dataset.dir, 'poses', 'livinglab_2', string(nearby_id(i)+1), db_name))
%     load(fullfile(params.dataset.dir, 'matfiles', 'livinglab_2', string(nearby_id(i)+1), db_name))
%     hold on; pcshow(reshape(XYZcut, [],3), reshape(RGBcut, [],3));
%     ax_x = [position', position' + R * [2,0,0]'];
%     ax_y = [position', position' + R * [0,2,0]'];
%     ax_z = [position', position' + R * [0,0,2]'];
%     hold on;
%     plot3(ax_x(1,:), ax_x(2,:), ax_x(3,:),'r', 'LineWidth', 3)
%     plot3(ax_y(1,:), ax_y(2,:), ax_y(3,:),'g', 'LineWidth', 3)
%     plot3(ax_z(1,:), ax_z(2,:), ax_z(3,:),'b', 'LineWidth', 3)
% end

%% test p3p
%imshow(fullfile(params.dataset.dir, 'cutouts', cell2mat(dblist{ii})))

R = P(:,1:3);
t = P(:,4);

Iq = imread(fullfile(params.dataset.dir, 'queries', qname));
Idb = imread(fullfile(params.dataset.dir, 'cutouts', dbname));

f = figure();
imshow(rgb2gray([Iq Idb]));hold on;
plot(tent_xq2d(1,:), tent_xq2d(2,:), 'b.')
plot(tent_xdb2d(1,:)+ size(Iq,2),tent_xdb2d(2,:),'b.')

plot(tent_xq2d(1,inls), tent_xq2d(2,inls), 'g.')
plot(tent_xdb2d(1,inls)+ size(Iq,2),tent_xdb2d(2,inls),'g.')
        


 points.x2 = tentatives_2d(3, :);
 points.y2 = tentatives_2d(4, :);
 points.x1 = tentatives_2d(1, :);
 points.y1 = tentatives_2d(2, :);
 points.color = 'r';
 points.facecolor = 'r';
 points.markersize = 60;
 points.linestyle = '-';
 points.linewidth = 1.0;
 show_matches2_vertical( Iq, Idb, points );

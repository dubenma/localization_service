function [RGBcut, XYZcut, depth] = projectMesh(meshPath, f, R, t, sensorSize, ortho, mag, projectMeshPyPath, headless)
% R = cameraToModel(1:3,1:3); % columns are bases of epsilon wrt model (see GVG)
% t = cameraToModel(1:3,4); % wrt model
% camera points to -z direction, having x on its right, y going up (right-handed CS)

inputPath = strcat(tempname(), '.mat');
outputPath = strcat(tempname(), '.mat');
save(inputPath, 'meshPath', 'f', 'R', 't', 'sensorSize', 'ortho', 'mag');

b = '/usr/local/cuda-9.0/lib64:/home/seberma3/.conda/envs/inlocul/lib:';

command = sprintf('LD_LIBRARY_PATH=%s PYOPENGL_PLATFORM=egl python3 "%s" %s %s', b, projectMeshPyPath, inputPath, outputPath);
%command = sprintf('PYOPENGL_PLATFORM=egl python3 "%s" %s %s', projectMeshPyPath, inputPath, outputPath);

disp(command)
[status, cmdout] = system(command);
disp(cmdout)

% load results
load(outputPath, 'RGBcut', 'XYZcut', 'depth')

% delete temporary files
delete(inputPath);
delete(outputPath);

end

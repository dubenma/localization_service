%Pocet kol mereni vykonu a vektory pro uklada ni namerenych vysledku
rounds = 100;
prof_rnd_points_no_for = zeros(1, rounds);
prof_rnd_points_for = zeros(1, rounds);
prof_proj_points_no_for = zeros(1, rounds);
prof_proj_points_for = zeros(1, rounds);
prof_norm_points_no_for = zeros(1, rounds);
prof_norm_points_for = zeros(1, rounds);

% Pocet 3D bodu
LEN = 10^7;

% Libovolna perspektivni kamera 
P = [1 2 -2 1; 2 5 1 7; -3 5 2 9];

for r=1:rounds
    disp("RND: " + r);
    disp("Random body ve 3D");
    tic;
    rnd = rand(3, LEN);
    prof_rnd_points_no_for(r) = toc;
    tic;
    for i=1:LEN
        rnd(1,i) = rand();
        rnd(2,i) = rand();
        rnd(3,i) = rand();
    end
    prof_rnd_points_for(r) = toc;
    
    
    
    disp("Projekce");
    tic;
    proj = P * [rnd; ones(1, LEN)];
    prof_proj_points_no_for(r) = toc;
    tic;
    for i=1:LEN
        proj(:,i) = P * [rnd(:,i); 1];
    end
    prof_proj_points_for(r) = toc;
    
    disp("normalizace");
    tic;
    projnorm = proj ./ proj(end, :);
    prof_norm_points_no_for = toc;
    
    tic;
    for i=1:LEN
        projnorm(:,i) = proj(:,i) / proj(end,i);
    end
    prof_norm_points_for = toc;
end

disp("Vytvoreni nahodnych bodu [bez for / s for]:");
disp(mean(prof_rnd_points_no_for));
disp(mean(prof_rnd_points_for));

disp("Projekce bodu [bez for / s for]:");
disp(mean(prof_proj_points_no_for));
disp(mean(prof_proj_points_for));

disp("Normalizace bodu [bez for / s for]:");
disp(mean(prof_norm_points_no_for));
disp(mean(prof_norm_points_for));


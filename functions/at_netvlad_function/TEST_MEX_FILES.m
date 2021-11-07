function TEST_MEX_FILES()

load("TEST_get_tcs_params.mat"); % Zabere cca 1,5 GB RAM.

mkl_erros = 0;
cublas_erros = 0;
eigen_erros = 0;

for dbim=1:numel(descs2)
    disp("Kontrola " + dbim + ". paru");
    desc2 = descs2{dbim};
    
    %% 2xN matice, tentativnich korespondenci. Idealne jsou vsechny stejneho rozmeru se stejnymi cisly.
    %  Vysledky jednotlivych knihoven se muzou kvuli zaokrouhlovacim chybam
    %  lisit. Proto matice mohou mit jiny pocet sloupcu (tent. koresp-cí),
    %  ale i jiná čísla.
    % Za chybu se povazuje chybejici TC, prebyvajici TC i jinak prirazena TC.
    tcs_original = at_dense_tc(desc1, desc2); tcs_original = int32(tcs_original(1:2, :));
    tcs_mkl = get_tcs_mkl(desc1, {desc2}); tcs_mkl = tcs_mkl{1};
    tcs_cublas = get_tcs_cublas(desc1, {desc2}); tcs_cublas = tcs_cublas{1};
    tcs_eigen = get_tcs_eig(desc1, {desc2}); tcs_eigen = tcs_eigen{1};
    
    %% Overi se pocet TC a vypise hlaseni, pokud nejsou stejne.
    num_tcs_original = size(tcs_original, 2);
    num_tcs_mkl = size(tcs_mkl, 2);
    num_tcs_cublas = size(tcs_cublas, 2);
    num_tcs_eigen = size(tcs_eigen, 2);
    
    if ~(num_tcs_original== num_tcs_mkl ...
        && num_tcs_original== num_tcs_cublas ... 
        && num_tcs_original==num_tcs_eigen)
        disp("Pocet nalezenych TC se v "+dbim+". paru lisi [Matlab, MKL, cuBLAS, Eigen]: ");
        disp([num_tcs_original num_tcs_mkl num_tcs_cublas num_tcs_eigen]);
    end
    
    %% Vsechny matice tentativnich korespondenci musi mit stejny rozmer pro snazsi vypocet, 
    %  coz znamena, ze vsechny budou mit 2 radky a max_corr_idx sloupcu (nejvyssi pouzity index tentativni korespondence),
    %  Pokud pro dany index nebude zadna TC, na druhem radku bude 0.
    % Prvni radek matic je tedy stejny (1...max_corr_idx). Lisi se jen druhe radky.
    max_corr_idx = max([tcs_original(1,:), tcs_mkl(1,:), tcs_cublas(1,:), tcs_eigen(1,:)]);
    
    tcs_original_aligned = tc_align(tcs_original, max_corr_idx);
    tcs_mkl = tc_align(tcs_mkl, max_corr_idx);
    tcs_cublas = tc_align(tcs_cublas, max_corr_idx);
    tcs_eigen = tc_align(tcs_eigen, max_corr_idx);
   
    %% Pocet odlisnych/chybejicich/prebyvajicich tentativnich korespondenci (chyb) muzeme spocitat prostym spocitanim 
    % nerovnajicich si indexu v maticich
    local_mkl_erros = sum(tcs_original_aligned ~= tcs_mkl, 'all');
    local_cublas_erros = sum(tcs_original_aligned ~= tcs_cublas, 'all');
    local_eigen_erros = sum(tcs_original_aligned ~= tcs_eigen, 'all');
    
    %% Vypsat pocet chyb v teto dvojici, pokud jsou nejake.
    if local_mkl_erros > 0; disp("MKL: Ve dvojici "+dbim+" je jinak prirazenych korespondenci: " + local_mkl_erros); end
    if local_cublas_erros > 0; disp("cuBLAS: Ve dvojici "+dbim+" je jinak prirazenych korespondenci: " + local_cublas_erros); end
    if local_eigen_erros > 0; disp("Eigen: Ve dvojici "+dbim+" je jinak prirazenych korespondenci: " + local_eigen_erros); end
    
    %% Celkovy pocet chyb jednotlivych knihoven za cely test
    mkl_erros = mkl_erros + local_mkl_erros;
    cublas_erros = cublas_erros + local_cublas_erros;
    eigen_erros = eigen_erros + local_eigen_erros;
end

disp("TEST skoncil");
disp("MKL ma jinak prirazenych korespondenci: " + mkl_erros);
disp("cuBLAS ma jinak prirazenych korespondenci: " + cublas_erros);
disp("Eigen ma jinak prirazenych korespondenci: " + eigen_erros);
end

function al = tc_align(tcs_2xN, targetWidth)
    al = [1:targetWidth; zeros(1, targetWidth)];
    al(2, tcs_2xN(1,:)) = tcs_2xN(2,:);
end
function env = environment()
    % Tohle vracim napevno
    %env = 'localization_service';
    env = 'ciirc'
    return; 

    % Proc to je sakra napsany takhle???? Proc se ma chovani kodu menit podle nazvu slozky, kde bezi? 
    % Notabene kdyz si je potrebuju dle potreby prejmenovavat!

    if contains(pwd, 'datagrid')
        env = 'cmp';
    elseif contains(pwd, 'repos')
        env = 'laptop';
    elseif contains(pwd, 'localization_service')
        env = 'localization_service';
    else
        env = 'ciirc';
    end
end
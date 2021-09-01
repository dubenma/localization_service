function env = environment()
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
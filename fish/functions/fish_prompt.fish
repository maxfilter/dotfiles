function fish_prompt
    # define prompt colors
    set -l normal_color     (set_color normal)
    set -l directory_color  (set_color $fish_color_quote 2> /dev/null; or set_color brown)
    set -g __fish_git_prompt_showcolorhints 'yes' 
    set -g __fish_git_prompt_color_branch 'green'
    
    # git prompt settings
    set -g __fish_git_prompt_use_informative_chars 'yes'
    set -g __fish_git_prompt_char_stateseparator ' '
    
    # begin prompt
    echo -n -s $directory_color (prompt_pwd) $normal_color 
    fish_git_prompt ' on %s' # concatenate git info to prompt
    echo -n ' '
    # end prompt
end

function mkcd
    if test (count $argv) -gt 1
        echo "Only one argument should be supplied" 1>&2
        return -1
    end
    set newdir $argv[1]
    mkdir -p $newdir
    and cd $newdir
end
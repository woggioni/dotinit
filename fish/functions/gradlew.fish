function gradlew
    set folder "."
    while true
        if test -f "$folder/gradlew"
            "$folder/gradlew" $argv
            return $status
        else if test "$folder" =  "/"
            gradle $argv
            return $status
        else
            set folder (realpath "$folder/../")
        end
    end
end

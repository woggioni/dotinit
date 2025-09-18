# config.nu
#
# Installed by:
# version = "0.104.1"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# This file is loaded after env.nu and before login.nu
#
# You can open this file in your default editor using:
# config nu
#
# See `help config nu` for more options
#
# You can remove these comments if you want or leave
# them for future reference.

use std/util "path add"

path add ($env.HOME | path join "bin")
path add ($env.HOME | path join ".local/bin")
path add ($env.HOME | path join ".cargo/bin")
alias hx = helix

$env.config.buffer_editor = "helix"
$env.config.show_banner = false
$env.EDITOR = "helix"
$env.config.history.max_size = 10000

$env.PROMPT_COMMAND = { ||
    let username = $env.USER
    let hostname = sys host | get hostname
    let current_dir = (pwd)
    
    $"($username)@($hostname) ($current_dir)"
}

def _gradlew [java_version: int, ...names: string] {
    while (pwd | $in != '/') {
        if (echo gradlew | path exists ) {
            let extra_jvm_properties = match $java_version {
                0 => []
                _ => [$"-Dorg.gradle.java.home=/usr/lib/jvm/java-($java_version)-openjdk"]
            }
            
            ./gradlew ...$extra_jvm_properties ...$names
            return
        } else {
            cd ..
        }
    }
    error make { msg: "No gradlew file found"}
}

def gradlew [...names: string] {
    _gradlew 0 ...$names
}
def gradlew8 [...names: string] {
    _gradlew 8 ...$names
}
def gradlew11 [...names: string] {
    _gradlew 11 ...$names
}
def gradlew17 [...names: string] {
    _gradlew 17 ...$names
}
def gradlew21 [...names: string] {
    _gradlew 21 ...$names
}

def --env mkcd [p: string] {
    mkdir $p
    cd $p
}

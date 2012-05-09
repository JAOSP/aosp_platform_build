#
# envsetup.sh - the intial purpose of this script created by The Android Open Source
# Project (AOSP) is to help set up necessary stuffs to fit your needs so that you 
# can get what you really desire. 
# 
# As time passes, however, the script has been expanded in to pretty much every
# aspect applied throughout The AOSP, not just including configuration. Therefore,
# at this point, couple ideas come to me to make life a whole lot easier, which
# cover as below:
#   a. Split all functions according to functionality into six topics:
#      generic - general-purpose functions, like help, croot, cgrep, etc.
#      configuration - setting functions, like choosecombo, lunch, tapas, etc.
#      build - compilation functions, like m, mm, mmm, etc.
#      debugging - helping track down issues, get bug reports, as well as
#                  analize performance, containing functions, like
#                  gdbclient, bugreports, systemstack, tracedmdump, ahat, etc.
#      testing - testing the code you want and validating changed code, relating
#                to functions, like testrunner, smoketest, etc.
#      reviewing - TODO: submmiting patches to The AOSP.
#   b. Bring in naming rules for functions defined here.
#   c. Add new functions, like get_function_list, shgrep, pygrep, etc. 
#   d. Rewrite some funtions, like help, sgrep, etc.  
#   e. Modify some fucntions, like gdbclient, systemstack, etc.
#   f. Add a tab completeion, _help
#   For more information, please take a look at itself.
#
# 
# For keeping source code consistent, readable, and maintainable, it is simply 
# necessary to draw out the conventions of coding style, as described as below: 
#   a. Put functions with the same logic under the same topic mentioned above
#   b. Classify function naming into three types,
#        exposed - meaning function names used by users with only single word, 
#                  not including underscores(_) and dashes(-), like help, croot,
#                  choosecombo, etc.
#        internal - indicating function names only invoked in-house with multiple
#                   words but combined with unsersocres(_).
#        tabcomplete - depicting funtions names for tab completion starting with 
#                      underscore(_) and then following the internal rule, but not
#                      with the function keyword.
#
#
# Copyright (C) 2008-2012 The Android Open Source Project
# Copyright (C) 2012 Samuel Omlin <samuel.omlin@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


###############################################################
#
# Generic - Define all funtions here with general purposes
#
###############################################################
# Get online help for exposed funtions
function help() 
{
    case $1 in 
        # Note that the names of these functions classified in to the corresponding 
        # topic above are arranged in a frequently used order.
        #
        # Generic
        croot)
            echo "Name: croot - go to the top tree"
            echo "Usage: croot"
            ;;
        cproj)
            echo "Name: cproj - go back to the root directory under the current"
            echo "              project"
            echo "Usage: cproj"
            ;;
        godir)
            echo "Name: godir - go to the directory containing certian directory"
            echo "              or file"
            echo "Usage: godir DIRECTORY|FILE"
            echo "Arguments: DIRECTORY that is the one you specify under"
            echo "                     the top tree, like (/)rild"
            echo "           FILE that is the one you specify under the top tree,"
            echo "                like rild.c"
            ;;
        cgrep)
            echo "Name: cgrep - grep on (*.c|cc|cpp|h) files under the current"
            echo "              directory"
            echo "Usage: cgrep PATTERN"
            echo "Arguments: PATTERN like keyword(s) or regexp"
            ;;
        jgrep)
            echo "Name: jgrep - grep on (*.java) files under the current directory"
            echo "Usage: jgrep PATTERN"
            echo "Arguments: PATTERN like keyword(s) or regexp"
            ;;
        sgrep)
            echo "Name: sgrep - grep on (*.S) files under the current directory"
            echo "Usage: sgrep PATTERN"
            echo "Arguments: PATTERN like keyword(s) or regexp"
            ;;
        resgrep)
            echo "Name: resgrep - grep on (res/*.xml) files under the current"
            echo "                directory"
            echo "Usage: resgrep PATTERN"
            echo "Arguments: PATTERN like keyword(s) or regexp"
            ;;
        shgrep)
            echo "Name: shgrep - grep on (*.sh) files under the current directory"
            echo "Usage: shgrep PATTERN"
            echo "Arguments: PATTERN like keyword(s) or regexp"
            ;;
        pygrep)
            echo "Name: pygrep - grep on (*.py) files under the current directory"
            echo "Usage: pygrep PATTERN"
            echo "Arguments: PATTERN like keyword(s) or regexp"
            ;;
        plgrep)
            echo "Name: plgrep - grep on (*.pl) files under the current directory"
            echo "Usage: plgrep PATTERN"
            echo "Arguments: PATTERN like keyword(s) or regexp"
            ;;
        mgrep)
            echo "Name: mgrep - grep on (*/Makefile|*/Makefile.*|*.make/mak/mk)"
            echo "              files under the current directory"
            echo "Usage: mgrep PATTERN"
            echo "Arguments: PATTERN like keyword(s) or regexp"
            ;;
        treegrep)
            echo "Name: treegrep - grep on (*.c|h|cpp|S|java|xml|sh|py|pl|mk) files"
            echo "                 under the current directory"
            echo "Usage: treegrep PATTERN"
            echo "Arguments: PATTERN like keyword(s) or regexp"
            ;;
        # Configuration
        choosetype)
            echo "Name: choosetype - choose build type for target product"
            echo "Usage: choosetype [BUILDTYPE]"
            echo "Arguments: BUILDTYPE containing <release|debug>"
            ;;
        chooseproduct)
            echo "Name: chooseproduct - choose build target product"
            echo "Usage: chooseproduct [PRODUCTNAME]"
            echo "Arguments: PRODUCTNAME containing <full|generic>|full_xxx|xxx"
            ;;
        choosevariant)
            echo "Name: choosevariant - choose build variant for target product"
            echo "Usage: choosevariant [BUILDVARIANT]"
            echo "Arguments: BUILDVARIANT containing <eng|user|userdebug>"
            ;;
        printconfig)
            echo "Name: printconfig - print config info for target product"
            echo "Usage: printconfig"
            ;;
        choosecombo)
            echo "Name: choosecombo - choose combo for target product"
            echo "Usage: choosecombo [BUILDTYPE] [PRODUCTNAME] [BUILDTYPE]"
            echo "Arguments: BUILDTYPE containing <release|debug>"
            echo "           PRODUCTNAME containing <full|generic>|full_xxx|xxx"
            echo "           BUILDVARIANT containing <eng|user|userdebug>"
            ;;
        lunch)
            echo "Name: lunch - configure target product and build variant"
            echo "Usage: lunch [PRODUCTNAME]-[BUILDVARIANT]"
            echo "Arguments: BUILDTYPE=<release>"
            echo "           PRODUCTNAME containing <full|generic>|full_xxx|xxx"
            echo "           BUILDVARIANT containing <eng|user|userdebug>"
            ;;
        tapas)
            echo "Name: choosecombo - configure build variant and app name(s)"
            echo "Usage: choosecombo [BUILDVARIANT] APPNAME [APPNAME]"
            echo "Arguments: BUILDTYPE=<release>"
            echo "           PRODUCTNAME=<full>"
            echo "           BUILDVARIANT containing <eng|user|userdebug>"
            echo "           APPNAME containing <all>|LOCAL_PACKAGE_NAME"
            ;;
        # Build
        m)
            echo "Name: m - make from the top tree"
            echo "Usage: m [OPTIONS] [TARGETS]"
            echo "OPTIOINS: refer to <man make>"
            echo "TARGETS: "
            echo "help              get common make targets"
            echo "clean             remove all built stuff under /out directory"
            echo "clobber           remove all built stuff under /out directory"
            echo "dataclean         remove all data partitions for user/emulator"
            echo "installclean      remove all changes between different build types"
            echo "sdk               "
            echo "cts               "
            echo "modules           get a list of names of all modules"
            echo "<MODULE|PACKAGE>  build a specified module/package defined in"
            echo "                  Android.mk"
            echo "clean-<MODULE|PACKAGE>"
            echo "snod              rebuild system image when change happens"
            echo "showcommands      show every command excuted"
            echo "----------------------Two Specific Targets------------------------"
            echo "PRODUCT-<PRODUCTNAME>-<BUILDVARIANT> Build target product without"
            echo "                                     setting up build environment"
            echo "                                     by build/envsetup.sh"
            echo "APP-<APPNAME> Build unbundled app without setting up"
            echo "              build environment by build/envsetup.sh"
            echo "------------------------------------------------------------------"
            echo "For many more targets, refer to <make help>"
            ;;
        mm)
            echo "Name: mm - build all modules/packages under the current directory"
            echo "Usage: mm [MODULE|PACKAGE]"
            echo "Arguments: "
            echo "MODULE indicating the name of module defined in Android.mk"
            echo "PACKAGE indicating the name of package defined in Android.mk"
            echo "-------------------------------NOTES------------------------------"
            echo "If mm is invoked from the tree top, MUST specify a name for module"
            echo "or package defined in Android.mk. Instead, nothing but mm itself"
            echo "is needed if mm did from the current directory including "
            echo "Android.mk or its parent one(s) including it."  
            ;;
        mmm)
            echo "Name: mmm - build all modules/packages under the supplied directory"
            echo "Usage: mmm [OPTIONS] [DIRECTORY [DIRECTORY] ...] [TARGET]"
            echo "OPTIOINS: refer to <man make>"
            echo "Arguments:"
            echo "DIRECTORY indicating a dir including a module/package or more"
            echo "TARGET including <snod|showcommands|dist|incrementaljavac>"
            ;;
        # Debugging
        pid)
            echo "Name: pid - print process id"
            echo "Usage: pid PROCESSNAME|PROCESSID"
            echo "Arguments: PROCESSNAME indicating a name of process on device"
            echo "           PROCESSID describing a id of process on device"
            ;;
        systemstack)
            echo "Name: systemstack - collect current stack trace of all threads in"
            echo "                    system process"
            echo "Usage: systemstack OPERATION"
            echo "Arguments: OPERATION including <dump|move>"
            echo "           <dump> collect all traces to /data/anr/traces.txt on"
            echo "                  target"
            echo "           <move> transport traces.txt from device to host"
            ;;
        gdbclient)
            echo "Name: gdbclient - debug a program living in user space"
            echo "Usage: gdbclient PROGRAM [BINARY] [:PORT]"
            echo "Arguments:"
            echo "PROGRAM that is a name or pid you will debug, though running on"
            echo "        device"
            echo "BINARY indicating a filename under /PRODUCT_OUT/symbols/system/bin"
            echo "       on host, default to <app_process>"
            echo "PORT describing a TCP port to communicate between device and host,"
            echo "     default to <5039>"
            echo "-------------------------------NOTES------------------------------"
            echo "If PROGRAM is definitely fallen into between <system_server> and"
            echo "<all-apps>, just issue gdbclient PROGRAM from the current command"
            echo "line will suffice"
            ;;
        keyevents)
            echo "Name: keyevents - assist in debugging with gdbclient"
            echo "Usage: keyevents KEYVALUE"
            echo "Arguments: KEYVALUE containing <home|menu|back>"
            ;;
        tracedmdump)
            echo "Name: tracedmdump - generate graphical call-stack diagrams"
            echo "Usage: tracedmdump TRACELOG"
            echo "Arguments: TRACELOG describing a name of trace log file"
            ;;
        ahat)
            echo "Name: ahat - profile heap for memory leaks for applications"
            echo "Usage: ahat [-d | -e | -s <serial number>] PID|PROGRAM"
            echo "Opetions: refer to 'adb -h'"
            echo "Arguments: PID describing a ID of process running on device"
            echo "           PROGRAM describing a name of program running on device"
            ;;
        bugreports)
            echo "Name: bugreports - get bug reports from device to host"
            echo "Usage: bugreports"
            ;;
        viewserver)
            echo "Name: viewserver - run view server"
            echo "Usage: viewserver STATUS"
            echo "Arguments: STATUS containing <start|stop|status>"
            ;;
        # Testing
        smoketest)
            echo "Name: smoketest - run system smoke tests on device"
            echo "Usage: smoketest"
            ;;
        testrunner)
            echo "Name: testrunner - run tests on device"
            echo "Usage: testrunner [OPTIONS] TESTNAMES"
            echo "Options: "
            echo "-h, --help            Show this help message and exit"
            echo "-l, --list-tests      To view the list of test names"
            echo "-b, --skip-build      Skip build - just launch"
            echo "-j X, --jobs=X        Number of make jobs when building"      
            echo "For more information, try 'testrunner <-h|--help>'"
            ;;
        # TODO: Reviewing
        # Generic
        help | *)
            echo "Name: help - get online help for exposed funtions"
            echo "Usage: help COMMAND or help <TAB>"
            echo "Arguments: COMMAND containing one of funtions in the following"
            echo "                   list:"
            local A
            A=""
            for i in $(get_function_list exposed); do
            A="$A $i"
            done
            echo $A
            ;;
    esac
}

# Tab completion to help
_help()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    
    COMPREPLY=( $(compgen -W "$(get_function_list exposed)" -- ${cur}) )
    return 0
}

# Get the list of functions
function get_function_list()
{
    local FUNC_LIST
    T=$(get_tree_top)
    
    case $1 in
        # Get a list of all names of functions defined here
        all)
            FUNC_LIST=$(cat $T/build/envsetup.sh | sed -n "/^function /s/function \([a-z_]*\).*/\1/p" | sort)
            ;;
        # Get a list of all names of functions with only a word not combined by 
        # a underscore(_)/dash(-) or more
        exposed)
            FUNC_LIST=$(cat $T/build/envsetup.sh | sed -n "/^function /s/function \([a-z_]*\).*/\1/p" | grep -e "^[a-z]*$" | sort)
            ;;
        # Get a list of all names of functions with a word or more combined by 
        # only a underscore(_)/dash (-) or more
        inter)
            FUNC_LIST=$(cat $T/build/envsetup.sh | sed -n "/^function /s/function \([a-z_]*\).*/\1/p" | grep -e "^[a-z]*[_][a-z_]*$" | sort)
            ;;
        # Get a list of all names of functions, with a word or more combined by 
        # only a underscore(_)/dash (-) or more, but starting with a underscore(_)
        complete)
            FUNC_LIST=$(cat $T/build/envsetup.sh | sed -n "s/\(^[_][a-z_]*\).*/\1/p" | sort)
            ;;
    esac
    
    echo ${FUNC_LIST[@]}
}

# Get the tree top
function get_tree_top
{
    local TOPFILE=build/core/envsetup.mk
    if [ -n "$TOP" -a -f "$TOP/$TOPFILE" ] ; then
        echo $TOP
    else
        if [ -f $TOPFILE ] ; then
            # The following circumlocution (repeated below as well) ensures
            # that we record the true directory name and not one that is
            # faked up with symlink names.
            PWD= /bin/pwd
        else
            # We redirect cd to /dev/null in case it's aliased to
            # a command that prints something as a side-effect
            # (like pushd)
            local HERE=$PWD
            T=
            while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
                cd .. > /dev/null
                T=`PWD= /bin/pwd`
            done
            cd $HERE > /dev/null
            if [ -f "$T/$TOPFILE" ]; then
                echo $T
            fi
        fi
    fi
}

# Go to the top tree
function croot()
{
    T=$(get_tree_top)
    if [ "$T" ]; then
        cd $T
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

# Go back to the root directory under the current project
function cproj()
{
    TOPFILE=build/core/envsetup.mk
    # We redirect cd to /dev/null in case it's aliased to
    # a command that prints something as a side-effect
    # (like pushd)

    local HERE=$PWD
    T=
    while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
        T=$PWD
        if [ -f "$T/Android.mk" ]; then
            cd $T
            return
        fi
        cd .. > /dev/null
    done

    cd $HERE > /dev/null
    echo "can't find Android.mk"
}

# Go to the directory containing certian directory or file
function godir() 
{
    if [[ -z "$1" ]]; then
        echo "Parameters given: Invalid. Try 'help godir'."
        return
    fi
    
    T=$(get_tree_top)
    if [[ ! -f $T/filelist ]]; then
        echo -n "Creating index..."
        (cd $T; find . -wholename ./out -prune -o -wholename ./.repo -prune -o -type f > filelist)
        echo " Done"
        echo ""
    fi
    
    local lines
    lines=($(grep "$1" $T/filelist | sed -e 's/\/[^/]*$//' | sort | uniq))
    if [[ ${#lines[@]} = 0 ]]; then
        echo "Not found"
        return
    fi
    
    local pathname
    local choice
    if [[ ${#lines[@]} > 1 ]]; then
        while [[ -z "$pathname" ]]; do
            local index=1
            local line
            for line in ${lines[@]}; do
                printf "%6s %s\n" "[$index]" $line
                index=$(($index + 1))
            done
            echo
            echo -n "Select one: "
            unset choice
            read choice
            if [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
                echo "Invalid choice"
                continue
            fi
            pathname=${lines[$(($choice-1))]}
        done
    else
        pathname=${lines[0]}
    fi
    cd $T/$pathname
}

# Grep on (*.c|cc|cpp|h) files under the current directory
function cgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' \) -print0 | xargs -0 grep --color -n "$@"
}

# Grep on (*.java) files under the current directory
function jgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f -name "*\.java" -print0 | xargs -0 grep --color -n "$@"
}

# Grep on (*.S) files under the current directory
function sgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f -name "*\.S" -print0 | xargs -0 grep --color -n "$@"
}

# Grep on (res/*.xml) files under the current directory
function resgrep()
{
    for dir in `find . -name .repo -prune -o -name .git -prune -o -type d -name res`; do find $dir -type f -name '*\.xml' -print0 | xargs -0 grep --color -n "$@"; done;
}

# Grep on (*.sh) files under the current directory
function shgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f -name "*\.sh" -print0 | xargs -0 grep --color -n "$@"
}

# Grep on (*.py) files under the current directory
function pygrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f -name "*\.py" -print0 | xargs -0 grep --color -n "$@"
}

# Grep on (*.pl) files under the current directory
function plgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f -name "*\.pl" -print0 | xargs -0 grep --color -n "$@"
}

# Grep on (*/Makefile|*/Makefile.*|*.make/mak/mk) files under the current directory
function mgrep()
{
    case `uname -s` in
        Darwin)
            find -E . -name .repo -prune -o -name .git -prune -o  -type f -iregex '.*/(Makefile|Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -print0 | xargs -0 grep --color -n "$@"
        ;;
        *)
            find . -name .repo -prune -o -name .git -prune -o -type f -regextype posix-egrep -iregex '(.*\/Makefile|.*\/Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -print0 | xargs -0 grep --color -n "$@"
        ;;
    esac
}

# Grep on (*.c|h|cpp|S|java|xml|sh|py|pl|mk) files under the current directory
function treegrep()
{
    case `uname -s` in
        Darwin)
            find -E . -name .repo -prune -o -name .git -prune -o -type f -iregex '.*\.(c|h|cpp|S|java|xml|sh|py|mk)' -print0 | xargs -0 grep --color -n -i "$@"
        ;;
        *)
            find . -name .repo -prune -o -name .git -prune -o -type f -regextype posix-egrep -iregex '.*\.(c|h|cpp|S|java|xml|sh|py|pl|mk)' -print0 | xargs -0 grep --color -n -i "$@"
        ;;
    esac
}

# Add all tab completions to the current shell environment
function add_tab_complete()
{
    local T dir f

    # Keep us from trying to run in something that isn't bash.
    if [ -z "${BASH_VERSION}" ]; then
        return
    fi

    # Keep us from trying to run in bash that's too old.
    if [ ${BASH_VERSINFO[0]} -lt 3 ]; then
        return
    fi

    # Add tab completions to functions
    complete -F _help help
    complete -F _lunch lunch

    dir="sdk/bash_completion"
    if [ -d ${dir} ]; then
        for f in `/bin/ls ${dir}/[a-z]*.bash 2> /dev/null`; do
            echo "including $f"
            . $f
        done
    fi
}


###############################################################
#
# Configuration - Define all funtions here with settings
#
###############################################################
# Get the value of a build variable as an absolute path
function get_abs_build_var()
{
    T=$(get_tree_top)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    (cd $T; CALLED_FROM_SETUP=true BUILD_SYSTEM=build/core \
      make --no-print-directory -C "$T" -f build/core/config.mk dumpvar-abs-$1)
}

# Get the exact value of a build variable
function get_build_var()
{
    T=$(get_tree_top)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    CALLED_FROM_SETUP=true BUILD_SYSTEM=build/core \
      make --no-print-directory -C "$T" -f build/core/config.mk dumpvar-$1
}

# Set bash title with target/user/host info
function set_bash_title()
{
    if [ "$STAY_OFF_MY_LAWN" = "" ]; then
        local product=$TARGET_PRODUCT
        local variant=$TARGET_BUILD_VARIANT
        local apps=$TARGET_BUILD_APPS
        if [ -z "$apps" ]; then
            export PROMPT_COMMAND="echo -ne \"\033]0;[${product}-${variant}] ${USER}@${HOSTNAME}: ${PWD}\007\""
        else
            export PROMPT_COMMAND="echo -ne \"\033]0;[$apps $variant] ${USER}@${HOSTNAME}: ${PWD}\007\""
        fi
    fi
}

# Force JAVA_HOME to point to java 1.6 if it isn't already set
function set_java_home() 
{
    if [ ! "$JAVA_HOME" ]; then
        case `uname -s` in
            Darwin)
                export JAVA_HOME=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home
                ;;
            *)
                export JAVA_HOME=/usr/lib/jvm/java-6-sun
                ;;
        esac
    fi
}

# Export various vars to set up a basic build environment
function set_paths()
{
    T=$(get_tree_top)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return
    fi

    ##################################################################
    #                                                                #
    #              Read me before you modify this code               #
    #                                                                #
    #   This function sets ANDROID_BUILD_PATHS to what it is adding  #
    #   to PATH, and the next time it is run, it removes that from   #
    #   PATH.  This is required so lunch can be run more than once   #
    #   and still have working paths.                                #
    #                                                                #
    ##################################################################

    # Note: on windows/cygwin, ANDROID_BUILD_PATHS will contain spaces
    # due to "C:\Program Files" being in the path.

    # out with the old
    if [ -n "$ANDROID_BUILD_PATHS" ] ; then
        export PATH=${PATH/$ANDROID_BUILD_PATHS/}
    fi
    if [ -n "$ANDROID_PRE_BUILD_PATHS" ] ; then
        export PATH=${PATH/$ANDROID_PRE_BUILD_PATHS/}
        # strip trailing ':', if any
        export PATH=${PATH/%:/}
    fi

    # and in with the new
    CODE_REVIEWS=
    prebuiltdir=$(get_abs_build_var ANDROID_PREBUILTS)

    # The gcc toolchain does not exists for windows/cygwin. In this case, do not reference it.
    export ANDROID_EABI_TOOLCHAIN=
    toolchaindir=toolchain/arm-linux-androideabi-4.4.x/bin
    if [ -d "$prebuiltdir/$toolchaindir" ]; then
        export ANDROID_EABI_TOOLCHAIN=$prebuiltdir/$toolchaindir
    fi

    export ARM_EABI_TOOLCHAIN=
    toolchaindir=toolchain/arm-eabi-4.4.3/bin
    if [ -d "$prebuiltdir/$toolchaindir" ]; then
        export ARM_EABI_TOOLCHAIN=$prebuiltdir/$toolchaindir
    fi

    export ANDROID_TOOLCHAIN=$ANDROID_EABI_TOOLCHAIN
    export ANDROID_QTOOLS=$T/development/emulator/qtools
    export ANDROID_BUILD_PATHS=:$(get_build_var ANDROID_BUILD_PATHS):$ANDROID_QTOOLS:$ANDROID_TOOLCHAIN:$ARM_EABI_TOOLCHAIN$CODE_REVIEWS
    export PATH=$PATH$ANDROID_BUILD_PATHS

    unset ANDROID_JAVA_TOOLCHAIN
    unset ANDROID_PRE_BUILD_PATHS
    if [ -n "$JAVA_HOME" ]; then
        export ANDROID_JAVA_TOOLCHAIN=$JAVA_HOME/bin
        export ANDROID_PRE_BUILD_PATHS=$ANDROID_JAVA_TOOLCHAIN:
        export PATH=$ANDROID_PRE_BUILD_PATHS$PATH
    fi

    unset ANDROID_PRODUCT_OUT
    export ANDROID_PRODUCT_OUT=$(get_abs_build_var PRODUCT_OUT)
    export OUT=$ANDROID_PRODUCT_OUT

    unset ANDROID_HOST_OUT
    export ANDROID_HOST_OUT=$(get_abs_build_var HOST_OUT)

    # needed for building linux on MacOS
    # TODO: fix the path
    #export HOST_EXTRACFLAGS="-I "$T/system/kernel_headers/host_include
}

# Set sequence number for ABS (Android Build System)
function set_sequence_number()
{
    export BUILD_ENV_SEQUENCE_NUMBER=10
}

# Export the path of the tree top to current environment
function set_tree_top()
{
    if [ ! "$ANDROID_BUILD_TOP" ]; then 
        export ANDROID_BUILD_TOP=$(get_tree_top)
    fi
}

# Set up all stuffs to build target product/device
function set_stuff_for_environment()
{
    set_bash_title
    set_java_home
    set_paths
    set_sequence_number
    set_tree_top
}

# Check to see if the supplied product is one we can build
function check_product()
{
    T=$(get_tree_top)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    CALLED_FROM_SETUP=true BUILD_SYSTEM=build/core \
        TARGET_PRODUCT=$1 \
        TARGET_BUILD_VARIANT= \
        TARGET_BUILD_TYPE= \
        TARGET_BUILD_APPS= \
        get_build_var TARGET_DEVICE > /dev/null
    # hide successful answers, but allow the errors to show
}

# Check to see if the supplied variant is valid
VARIANT_CHOICES=(user userdebug eng)
function check_variant()
{
    for v in ${VARIANT_CHOICES[@]}
    do
        if [ "$v" = "$1" ]
        then
            return 0
        fi
    done
    return 1
}

# Choose build type for target product
function choosetype()
{
    echo "Build type choices are:"
    echo "     1. release"
    echo "     2. debug"
    echo

    local DEFAULT_NUM DEFAULT_VALUE
    DEFAULT_NUM=1
    DEFAULT_VALUE=release

    export TARGET_BUILD_TYPE=
    local ANSWER
    while [ -z $TARGET_BUILD_TYPE ]
    do
        echo -n "Which would you like? ["$DEFAULT_NUM"] "
        if [ -z "$1" ] ; then
            read ANSWER
        else
            echo $1
            ANSWER=$1
        fi
        case $ANSWER in
        "")
            export TARGET_BUILD_TYPE=$DEFAULT_VALUE
            ;;
        1 | release)
            export TARGET_BUILD_TYPE=release
            ;;
        2 | debug)
            export TARGET_BUILD_TYPE=debug
            ;;
        *)
            echo
            echo "I didn't understand your response.  Please try again."
            echo
            ;;
        esac
        if [ -n "$1" ] ; then
            break
        fi
    done

    set_stuff_for_environment
}

# This function chooses a TARGET_PRODUCT by picking a product by name.
# It finds the list of products by finding all the AndroidProducts.mk
# files and looking for the product specific filenames in them.
function chooseproduct()
{
# Find the list of all products by looking for all AndroidProducts.mk files under the
# device/, vendor/ and build/target/product/ directories and look for the format
# LOCAL_DIR/<ProductSpecificFile.mk> and extract the name ProductSpecificFile from it.
# This will give the list of all products that can be built using choosecombo

    local -a prodlist

# Find all AndroidProducts.mk files under the dirs device/, build/target/ and vendor/
# Extract lines containing .mk from them
# Extract lines containing LOCAL_DIR
# Extract the name of the product specific file

    prodlist=(`/usr/bin/find device/ build/target/ vendor/ -name AndroidProducts.mk 2>/dev/null|
    xargs grep -h \.mk|
    grep LOCAL_DIR|
    cut -d'/' -f2|cut -d' ' -f1|sort|uniq|cut -d'.' -f1`)

    local index=1
    local p
    echo "Product choices are:"
    for p in ${prodlist[@]}
    do
        echo "     $index. $p"
        let "index = $index + 1"
    done

    if [ "x$TARGET_PRODUCT" != x ] ; then
        default_value=$TARGET_PRODUCT
    else
        default_value=full
    fi

    export TARGET_PRODUCT=
    local ANSWER
    while [ -z "$TARGET_PRODUCT" ]
    do
        echo "You can also type the name of a product if you know it."
        echo -n "Which product would you like? [$default_value] "
        if [ -z "$1" ] ; then
            read ANSWER
        else
            echo $1
            ANSWER=$1
        fi

        if [ -z "$ANSWER" ] ; then
            export TARGET_PRODUCT=$default_value
        elif (echo -n $ANSWER | grep -q -e "^[0-9][0-9]*$") ; then
            local poo=`echo -n $ANSWER`
            if [ $poo -le ${#prodlist[@]} ] ; then
                export TARGET_PRODUCT=${prodlist[$(($ANSWER-1))]}
            else
                echo "** Bad product selection: $ANSWER"
            fi
        else
            if check_product $ANSWER
            then
                export TARGET_PRODUCT=$ANSWER
            else
                echo "** Not a valid product: $ANSWER"
            fi
        fi
        if [ -n "$1" ] ; then
            break
        fi
    done

    set_stuff_for_environment
}


function choosevariant()
{
    echo "Variant choices are:"
    local index=1
    local v
    for v in ${VARIANT_CHOICES[@]}
    do
        # The product name is the name of the directory containing
        # the makefile we found, above.
        echo "     $index. $v"
        index=$(($index+1))
    done

    local default_value=eng
    local ANSWER

    export TARGET_BUILD_VARIANT=
    while [ -z "$TARGET_BUILD_VARIANT" ]
    do
        echo -n "Which would you like? [$default_value] "
        if [ -z "$1" ] ; then
            read ANSWER
        else
            echo $1
            ANSWER=$1
        fi

        if [ -z "$ANSWER" ] ; then
            export TARGET_BUILD_VARIANT=$default_value
        elif (echo -n $ANSWER | grep -q -e "^[0-9][0-9]*$") ; then
            if [ "$ANSWER" -le "${#VARIANT_CHOICES[@]}" ] ; then
                export TARGET_BUILD_VARIANT=${VARIANT_CHOICES[$(($ANSWER-1))]}
            fi
        else
            if check_variant $ANSWER
            then
                export TARGET_BUILD_VARIANT=$ANSWER
            else
                echo "** Not a valid variant: $ANSWER"
            fi
        fi
        if [ -n "$1" ] ; then
            break
        fi
    done
}

function printconfig()
{
    T=$(get_tree_top)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    get_build_var report_config
}

function choosecombo()
{
    choosetype $1

    echo
    echo
    chooseproduct $2

    echo
    echo
    choosevariant $3

    echo
    set_stuff_for_environment
    printconfig
}

# Clear this variable.  It will be built up again when the vendorsetup.sh
# files are included at the end of this file.
unset LUNCH_MENU_CHOICES
function add_lunch_combo()
{
    local new_combo=$1
    local c
    for c in ${LUNCH_MENU_CHOICES[@]} ; do
        if [ "$new_combo" = "$c" ] ; then
            return
        fi
    done
    LUNCH_MENU_CHOICES=(${LUNCH_MENU_CHOICES[@]} $new_combo)
}

function print_lunch_menu()
{
    local uname=$(uname)
    echo
    echo "You're building on" $uname
    echo
    echo "Lunch menu... pick a combo:"

    local i=1
    local choice
    for choice in ${LUNCH_MENU_CHOICES[@]}
    do
        echo "     $i. $choice"
        i=$(($i+1))
    done

    echo
}


function lunch()
{
    local answer

    if [ "$1" ] ; then
        answer=$1
    else
        print_lunch_menu
        echo -n "Which would you like? [full-eng] "
        read answer
    fi

    local selection=

    if [ -z "$answer" ]
    then
        selection=full-eng
    elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
    then
        if [ $answer -le ${#LUNCH_MENU_CHOICES[@]} ]
        then
            selection=${LUNCH_MENU_CHOICES[$(($answer-1))]}
        fi
    elif (echo -n $answer | grep -q -e "^[^\-][^\-]*-[^\-][^\-]*$")
    then
        selection=$answer
    fi

    if [ -z "$selection" ]
    then
        echo
        echo "Invalid lunch combo: $answer"
        return 1
    fi

    export TARGET_BUILD_APPS=

    local product=$(echo -n $selection | sed -e "s/-.*$//")
    check_product $product
    if [ $? -ne 0 ]
    then
        echo
        echo "** Don't have a product spec for: '$product'"
        echo "** Do you have the right repo manifest?"
        product=
    fi

    local variant=$(echo -n $selection | sed -e "s/^[^\-]*-//")
    check_variant $variant
    if [ $? -ne 0 ]
    then
        echo
        echo "** Invalid variant: '$variant'"
        echo "** Must be one of ${VARIANT_CHOICES[@]}"
        variant=
    fi

    if [ -z "$product" -o -z "$variant" ]
    then
        echo
        return 1
    fi

    export TARGET_PRODUCT=$product
    export TARGET_BUILD_VARIANT=$variant
    export TARGET_BUILD_TYPE=release

    echo

    set_stuff_for_environment
    printconfig
}

# Tab completion for lunch()
_lunch()
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    COMPREPLY=( $(compgen -W "${LUNCH_MENU_CHOICES[*]}" -- ${cur}) )
    return 0
}

# Configures the build to build unbundled apps.
# Run tapas with one ore more app names (from LOCAL_PACKAGE_NAME)
function tapas()
{
    local variant=$(echo -n $(echo $* | xargs -n 1 echo | grep -E '^(user|userdebug|eng)$'))
    local apps=$(echo -n $(echo $* | xargs -n 1 echo | grep -E -v '^(user|userdebug|eng)$'))

    if [ $(echo $variant | wc -w) -gt 1 ]; then
        echo "tapas: Error: Multiple build variants supplied: $variant"
        return
    fi
    if [ -z "$variant" ]; then
        variant=eng
    fi
    if [ -z "$apps" ]; then
        apps=all
    fi

    export TARGET_PRODUCT=full
    export TARGET_BUILD_VARIANT=$variant
    export TARGET_BUILD_TYPE=release
    export TARGET_BUILD_APPS=$apps

    set_stuff_for_environment
    printconfig
}


###############################################################
#
# Build - Define all funtions here for building
#
###############################################################
function m()
{
    T=$(get_tree_top)
    if [ "$T" ]; then
        make -C $T $@
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function find_makefile()
{
    TOPFILE=build/core/envsetup.mk
    # We redirect cd to /dev/null in case it's aliased to
    # a command that prints something as a side-effect
    # (like pushd)
    local HERE=$PWD
    T=
    while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
        T=$PWD
        if [ -f "$T/Android.mk" ]; then
            echo $T/Android.mk
            cd $HERE > /dev/null
            return
        fi
        cd .. > /dev/null
    done
    cd $HERE > /dev/null
}

function mm()
{
    # If we're sitting in the root of the build tree, just do a
    # normal make.
    if [ -f build/core/envsetup.mk -a -f Makefile ]; then
        make $@
    else
        # Find the closest Android.mk file.
        T=$(get_tree_top)
        local M=$(find_makefile)
        # Remove the path to top as the makefilepath needs to be relative
        local M=`echo $M|sed 's:'$T'/::'`
        if [ ! "$T" ]; then
            echo "Couldn't locate the top of the tree.  Try setting TOP."
        elif [ ! "$M" ]; then
            echo "Couldn't locate a makefile from the current directory."
        else
            ONE_SHOT_MAKEFILE=$M make -C $T all_modules $@
        fi
    fi
}

function mmm()
{
    T=$(get_tree_top)
    if [ "$T" ]; then
        local MAKEFILE=
        local ARGS=
        local DIR TO_CHOP
        local DASH_ARGS=$(echo "$@" | awk -v RS=" " -v ORS=" " '/^-.*$/')
        local DIRS=$(echo "$@" | awk -v RS=" " -v ORS=" " '/^[^-].*$/')
        for DIR in $DIRS ; do
            DIR=`echo $DIR | sed -e 's:/$::'`
            if [ -f $DIR/Android.mk ]; then
                TO_CHOP=`(cd -P -- $T && pwd -P) | wc -c | tr -d ' '`
                TO_CHOP=`expr $TO_CHOP + 1`
                START=`PWD= /bin/pwd`
                MFILE=`echo $START | cut -c${TO_CHOP}-`
                if [ "$MFILE" = "" ] ; then
                    MFILE=$DIR/Android.mk
                else
                    MFILE=$MFILE/$DIR/Android.mk
                fi
                MAKEFILE="$MAKEFILE $MFILE"
            else
                if [ "$DIR" = snod ]; then
                    ARGS="$ARGS snod"
                elif [ "$DIR" = showcommands ]; then
                    ARGS="$ARGS showcommands"
                elif [ "$DIR" = dist ]; then
                    ARGS="$ARGS dist"
                elif [ "$DIR" = incrementaljavac ]; then
                    ARGS="$ARGS incrementaljavac"
                else
                    echo "No Android.mk in $DIR."
                    return 1
                fi
            fi
        done
        ONE_SHOT_MAKEFILE="$MAKEFILE" make -C $T $DASH_ARGS all_modules $ARGS
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}


###############################################################
#
# Debugging - Define all funtions here for debugging
#
###############################################################
function pid()
{
    local PID
    if [ "$1" ] ; then
        if [[ "$1" =~ ^[0-9]+$ ]]; then
            if [ $(adb shell ps | grep $1) ]; then
                PID="$1"
            fi
        else
            PID=$(adb shell ps | fgrep $1 | sed -e 's/[^ ]* *\([0-9]*\).*/\1/')
        fi
    fi
    echo "$PID"
}

# systemstack - dump the current stack trace of all threads in the system process
# to the usual ANR traces file
function systemstack()
{
    case $1 in
        dump)
            adb shell echo '""' '>>' /data/anr/traces.txt && adb shell chmod 776 /data/anr/traces.txt && adb shell kill -3 $(pid system_server)
            ;;
        move)
            local traces=(`adb shell ls /data/anr/traces.txt`)
            if [ "$traces" ]; then
                adb pull /data/anr/traces.txt
            else
                echo "/data/anr/traces.txt on device: does not exist."
                echo "Try 'systemstack dump' first."
            fi
            ;;
        *) 
            echo "Parameters given: Invalid. Try 'help systemstack'."
            ;;
    esac
}

function gdbclient()
{
    # Check if these environment variables necessary to run gdb are set
    if [ -z $JAVA_HOME ]; then
        set_jave_home
    fi
    if [ -z $ANDROID_EABI_TOOLCHAIN -o -z $ARM_EABI_TOOLCHAIN ]; then
        set_paths
    fi
    
    # Run gdbserver on device and gdb itself on host separately
    local OUT_ROOT=$(get_abs_build_var PRODUCT_OUT)
    local OUT_SYMBOLS=$(get_abs_build_var TARGET_OUT_UNSTRIPPED)
    local OUT_SO_SYMBOLS=$(get_abs_build_var TARGET_OUT_SHARED_LIBRARIES_UNSTRIPPED)
    local OUT_EXE_SYMBOLS=$(get_abs_build_var TARGET_OUT_EXECUTABLES_UNSTRIPPED)
    local PREBUILTS=$(get_abs_build_var ANDROID_PREBUILTS)
    local PROG, BIN, PORT
    local PID
    if [ ! "$OUT_ROOT" -a ! "$PREBUILTS" ]; then
        echo "Unable to determine build system output dir."
        return
    else
        case $# in
            1)
                PID=$(pid $1)
                if [ "$PID" ]; then
                    PROG=$1
                    BIN="app_process"
                    PORT=":5039" 
                else
                    PID=
                fi       
                ;;
            2)
                PID=$(pid $1)
                if [ "$PID" ]; then
                    PROG=$1
                else
                    PID=
                fi
                if [ -f $OUT_EXE_SYMBOLS/$2 ]; then
                    BIN=$2
                else
                    BIN="app_process"
                fi
                if (echo $2 | grep -e '^[:][0-9]*$'); then
                    PORT=$2
                elif (echo $2 | grep -e '^[0-9]*$'); then
                    PORT=":$2"
                else
                    PORT=":5039"
                fi
                ;;
            3)
                PID=$(pid $1)
                if [ $PID ]; then
                    PROG=$1
                else
                    PID=
                fi
                if [ -f $OUT_EXE_SYMBOLS/$2 ]; then
                    BIN=$2
                else
                    BIN=
                fi
                if (echo $3 | grep -e '^[:][0-9]*$'); then
                    PORT=$3
                elif (echo $3 | grep -e '^[0-9]*$'); then
                    PORT=":$3"
                else
                    PORT=
                fi
                ;;
            *)
                echo "Parameters given: Invalid. Try 'help gdbclient'."
                return
        esac
        
        if [ ! "$PID" -a "$PROG" ]; then
            echo "gdbserver: Loading $PROG on device..."
            adb shell gdbserver $PORT /system/bin/$PROG
            sleep 2
            echo "gdbserver: Loading done on device"
        fi
        PID=$(pid $PROG)
        if [ "$PID" ]; then
            if [ $PROG -a $BIN -a $PORT ]; then
                echo "gdbserver: Attaching $PROG on device..."
                adb forward "tcp$PORT" "tcp$PORT"
                adb shell gdbserver $PORT --attach $PID &
                sleep 2
                echo "gdbserver: Attaching done on device"
            fi
        fi

        echo >|"$OUT_ROOT/gdbclient.cmds" "set solib-absolute-prefix $OUT_SYMBOLS"
        echo >>"$OUT_ROOT/gdbclient.cmds" "set solib-search-path $OUT_SO_SYMBOLS"
        echo >>"$OUT_ROOT/gdbclient.cmds" "target remote $PORT"
        echo >>"$OUT_ROOT/gdbclient.cmds" ""

        echo "gdb: Loading $BIN on host..."
        arm-linux-androideabi-gdb -x "$OUT_ROOT/gdbclient.cmds" "$OUT_EXE_SYMBOLS/$BIN"
        echo "gdb: Loading done on host."
    fi
}

function keyevents()
{
    case $1 in
        home)
            adb shell input keyevent 3
            ;;
        menu)
            adb shell input keyevent 82
            ;;
        back)
            adb shell input keyevent 4
            ;;
        *)
            echo "Parameters given: Invalid. Try 'help keyevents'."
            ;;
    esac  
}

# Generate graphical call-stack diagrams from the trace log file specified 
function tracedmdump()
{
    T=$(get_tree_top)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree. Try setting TOP."
        return
    fi
    
    local OUT_ROOT=$(get_abs_build_var PRODUCT_OUT)
    if [ ! "$OUT_ROOT" ]; then
        echo "Unable to determine build system output dir."
        return
    else
        local KERNEL=$T/prebuilt/android-arm/kernel/vmlinux-qemu
        local TRACE=$1
        if [ ! "$TRACE" ] ; then
            echo "Parameters given: Invalid. Try 'help tracedmdump'."
            return
        fi

        if [ ! -r "$KERNEL" ] ; then
            echo "Error: cannot find kernel: '$KERNEL'."
            return
        fi

        local BASETRACE=$(basename $TRACE)
        if [ "$BASETRACE" = "$TRACE" ] ; then
            TRACE=$OUT_ROOT/traces/$TRACE
        fi

        echo "post-processing traces..."
        rm -f $TRACE/qtrace.dexlist
        post_trace $TRACE
        if [ $? -ne 0 ]; then
            echo "***"
            echo "*** Error: malformed trace.  Did you remember to exit the emulator?"
            echo "***"
            return
        fi
        echo "generating dexlist output..."
        /bin/ls $OUT_ROOT/system/framework/*.jar $OUT_ROOT/system/app/*.apk $AOUT_ROOT/data/app/*.apk 2>/dev/null | xargs dexlist > $TRACE/qtrace.dexlist
        echo "generating dmtrace data..."
        q2dm -r $AOUT_ROOT/symbols $TRACE $KERNEL $TRACE/dmtrace || return
        echo "generating html file..."
        dmtracedump -h $TRACE/dmtrace >| $TRACE/dmtrace.html || return
        echo "done, see $TRACE/dmtrace.html for details"
        echo "or run:"
        echo "    traceview $TRACE/dmtrace"
    fi
}

# Communicate with a running device or emulator, set up necessary state,
# and run the hat command.
function ahat()
{
    # Process standard adb options
    local adbOptions
    if [ "$1" = "-d" -o "$1" = "-e" ]; then
        adbOptions=$1
        shift 1
    elif [ "$1" = "-s" ]; then
        adbOptions="$1 $2"
        shift 2
    fi

    local PID=$(pid $1)
    if [ ! "$PID" ]; then
        echo "Parameters given: Invalid. Try 'help ahat'."
        return
    else
        if [ -z $(which hat) ]; then
            echo "Hat: Not installed under /usr/bin directory."
            return
        fi

        # Issue "am" command to cause the hprof dump
        local devFile=/sdcard/hprof-$PID
        echo "Poking $PID and waiting for data..."
        adb ${adbOptions} shell am dumpheap $PID $devFile
        echo "Press enter when logcat shows \"hprof: heap dump completed\""
        echo -n "> "
        read

        local localFile=/tmp/$$-hprof
        echo "Retrieving file $devFile..."
        adb ${adbOptions} pull $devFile $localFile
        adb ${adbOptions} shell rm $devFile
        echo "Running hat on $localFile"
        echo "View the output by pointing your browser at http://localhost:7000/"
        echo ""
        hat $localFile
    fi
}

function bugreports()
{
    local reports=(`adb shell ls /sdcard/bugreports | tr -d '\r'`)
    if [ ! "$reports" ]; then
        echo "Could not locate any bugreports."
        return
    fi

    local report
    for report in ${reports[@]}
    do
        echo "/sdcard/bugreports/${report}"
        adb pull /sdcard/bugreports/${report} ${report}
        gunzip ${report}
    done
}

function viewserver()
{
    case $1 in
        start)
            local port
            local default=4939
            if [ $# -gt 1 ]; then
                if (echo -n $2 | grep -e "^[0-9][0-9]*$"); then
                    port=$2
                fi
            else
                port=$default
            fi
            adb shell service call window 1 i32 $port
            ;;
        stop)
            adb shell service call window 2
            ;;
        status)
            adb shell service call window 3
            ;;
        *)
            echo "Parameters given: Invalid. Try 'help viewserver'."
            ;;
    esac
}


###############################################################
#
# Testing - Define all funtions here for testing
#
###############################################################
function smoketest()
{
    T=$(get_tree_top)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi
    
    local OUT_ROOT=$(get_abs_build_var PRODUCT_OUT)
    if [ ! "$OUT_ROOT" ]; then
        echo "Couldn't locate output dir.  Try running 'lunch' first." >&2
        return
    fi

    (cd "$T" && mmm tests/SmokeTest) &&
      adb uninstall com.android.smoketest > /dev/null &&
      adb uninstall com.android.smoketest.tests > /dev/null &&
      adb install $OUT_ROOT/data/app/SmokeTestApp.apk &&
      adb install $OUT_ROOT/data/app/SmokeTest.apk &&
      adb shell am instrument -w com.android.smoketest.tests/android.test.InstrumentationTestRunner
}

function testrunner()
{
    T=$(get_tree_top)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP." >&2
        return
    fi

    # In the process of building tests by Android Build System to run on device, 
    # there are a bunch of env vars like ANDROID_BUILD_TOP to be needed. So, do 
    # here, just in case they could never be set.
    set_tree_top
    
    # When running the command 'testrunner --help' or 'testrunner <testname>' from
    # the command line, it's most likely to bump into such a error message,
    # saying '/usr/bin/python2.4: bad interpreter: No such file or directory'.
    # And, as we can know from (http://source.android.com/source/initializing.html),
    # this version of python to build the AOSP is against between 2.5 and 2.7.
    # Therefore, python2.4 out there in current source tree should be considered
    # obsolete, when comparing to the source tree. As a result, matching up with 
    # the version available is exactly a reasonable solution out there to fix the 
    # issue up.
    ($T/development/testrunner/runtest.py $@)
}


#####################################################################
#
# TODO: Reviewing - Define all funtions here for submitting patches
#
#####################################################################


#####################################################################
#
#                     Code snippets
#
#####################################################################
# Check if the present shell running this script is '/bin/bash'
if [ "x$SHELL" != "x/bin/bash" ]; then
    case `ps -o command -p $$` in
        *bash*)
            ;;
        *)
            echo "WARNING: Only bash is supported, use of other shell would lead to"
            echo "         erroneous results"
            ;;
    esac
fi

# Add the default lunch comboes here
add_lunch_combo full-eng
add_lunch_combo full_x86-eng
add_lunch_combo vbox_x86-eng

# Execute the contents of any vendorsetup.sh files we can find.
for f in `/bin/ls vendor/*/vendorsetup.sh vendor/*/*/vendorsetup.sh device/*/*/vendorsetup.sh 2> /dev/null`
do
    echo "including $f"
    . $f
done
unset f

add_tab_complete

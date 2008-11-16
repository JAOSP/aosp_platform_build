if [[ "x$ANDROID_JAVA_HOME" != x && -e $ANDROID_JAVA_HOME/lib/tools.jar ]] ; then
    echo $ANDROID_JAVA_HOME/lib/tools.jar
else
    JAVAC=$(which javac)
    if [ -z "$JAVAC" ] ; then
	echo "Please-install-JDK-5.0,-update-12-or-higher,-which-you-can-download-from-java.sun.com"
	exit 1
    fi

    # XXX: on FreeBSD javac is symlink to javawrapper.sh (javavm),
    #   which setups environment for one of installed JRE/JDK.
    #   we request dryrun to get JAVA_HOME
    if [[ `uname` == FreeBSD ]]; then
	
	JAVA_HOME=`env JAVAVM_DRYRUN=yes JAVA_VERSION=$1 /usr/local/bin/java | grep '^JAVA_HOME' | cut -c11-`
	
	if [ -z "$JAVA_HOME" ]; then
		echo "ERROR: JDK is installed incorrectly" > /dev/stderr
		exit 1
	fi
	    
	if [ -e $JAVA_HOME/lib/tools.jar ]; then
		echo $JAVA_HOME/lib/tools.jar
		exit 0
	fi
	    
	echo "ERROR: JAVA_HOME contains no lib/tools.jar file" > /dev/stderr
	exit 1
    else
        while [ -L $JAVAC ] ; do
	    LSLINE=$(ls -l $JAVAC)
    	    JAVAC=$(echo -n $LSLINE | sed -e "s/.* -> //")
	done
    fi
    echo $JAVAC | sed -e "s:\(.*\)/bin/java.*:\\1/lib/tools.jar:"
fi

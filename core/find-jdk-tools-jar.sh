if [ "x$ANDROID_JAVA_HOME" != x ] && [ -e "$ANDROID_JAVA_HOME/lib/tools.jar" ] ; then
    echo $ANDROID_JAVA_HOME/lib/tools.jar
else
    JAVAC=$(which javac)
    if [ -z "$JAVAC" ] ; then
	echo "Please-install-JDK-5.0,-update-12-or-higher,-which-you-can-download-from-java.sun.com"
	exit 1
    fi

    # XXX: on FreeBSD javac is symlink to javawrapper.sh (javawm),
    #   which setups environment for one of installed JRE/JDK.
    #   it's possible to copy most of setJavaHome() function,
    #   however most probably current JRE is first line in
    #   /usr/local/etc/javavms
    if [[ `uname` == FreeBSD ]]; then
	if [[ ! -e /usr/local/etc/javavms ]] ; then
	    echo "There is no such file, check JDK installation" > /dev/stderr
	    exit 1
	fi

	JAVAC=$(cat /usr/local/etc/javavms | head -n 1)
    else
        while [ -L $JAVAC ] ; do
	    LSLINE=$(ls -l $JAVAC)
    	    JAVAC=$(echo -n $LSLINE | sed -e "s/.* -> //")
	done
    fi
    echo $JAVAC | sed -e "s:\(.*\)/bin/java.*:\\1/lib/tools.jar:"
fi

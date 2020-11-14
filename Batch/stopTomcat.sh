export CATALINA_HOME="/opt/tomcat"
export CATALINA_BASE="$HOME/www"
export JAVA_HOME="/opt/java"
export PATH="$JAVA_HOME/bin:$CATALINA_HOME/bin:$PATH"

function stop {
    echo "Stopping Tomcat"
    catalina.sh stop

    echo "waiting for tomcat to stop"
    TEST=$(pgrep -lU ${LOGNAME}, java)
    while [ "${TEST}" != "" ]; do
        sleep 10
        echo "Processo attivo - ${TEST}"
        TEST=$(pgrep -lU ${LOGNAME}, java)
    done
    echo "Tomcat stopped ${TEST}"
}
 
stop



export CATALINA_HOME="/opt/tomcat"
export CATALINA_BASE="$HOME/www"
export CATALINA_OPTS="-Xms1024M -Xmx1024M -XX:PermSize=64m -XX:MaxPermSize=256m 
-Djava.awt.headless=true -Dhttp.proxyHost=proxy -Dhttp.proxyPort=8080"
export JAVA_HOME="/opt/java"
export PATH="$JAVA_HOME/bin:$CATALINA_HOME/bin:$PATH"

catalina.sh start

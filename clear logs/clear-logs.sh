dirs=(
'/home/wmw/ferramentas/apache-tomcat-UPHOM/logs/' '/home/wmw/ferramentas/apache-tomcat-UPHOM/log/'
'/home/wmw/ferramentas/apache-tomcat-UPPRD/logs/' '/home/wmw/ferramentas/apache-tomcat-UPPRD/log/'
'/home/wmw/ferramentas/apache-tomcat-WVHOM/logs/' '/home/wmw/ferramentas/apache-tomcat-WVHOM/log/'
'/home/wmw/ferramentas/apache-tomcat-WVPRD/logs/' '/home/wmw/ferramentas/apache-tomcat-WVPRD/log/'
)

echo ${dirs[@]}

#elimina arquivos .log passados 15 dias
for i in "${dirs[@]}"; do find "$i" -name "*.log" -type f -mtime +15 -exec rm -f {} \;; done

#elimina arquivos .txt passados 15 dias
for i in "${dirs[@]}"; do find "$i" -name "*.txt" -type f -mtime +15 -exec rm -f {} \;; done

#limpa arquivo catalina.out
for i in "${dirs[@]}"; do truncate -s 0 "$i/catalina.out"; done


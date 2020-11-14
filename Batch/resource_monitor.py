# Script per monitorare lo spazio disco di una macchina unix
# Lo script esegue il comando 'df -hP' e valuta la quinta colonna ('Use') confrontandola con la variabile threshold: se il valore letto supera questa soglia, la riga viene
# salvata in una variabile di errore. Alla fine, viene inviata una mail ad alta priorita'

import subprocess, smtplib
from email.mime.text import MIMEText

# Soglia di allarme
threshold = 90

# Nome dell'ambiente
serverName = 'CB04 - nodo 1'

def set_message(inputMessage):
        errorMessage = "Server " + serverName + " running out of disk space:"

        hostname = subprocess.Popen(['hostname'], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        hostname.wait()

        for line in hostname.stdout:
            errorMessage += "\nHostname: " + line

        ip = subprocess.Popen(['hostname', '-I'], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        ip.wait()

        for line in ip.stdout:
            errorMessage += "\nIP: " + line

        errorMessage +=  "\nPartizione\tSpazio(%)\n" + inputMessage
        return errorMessage


def report_mail(message):
        msg = MIMEText(message)

        msg["Subject"] = "Low disk space warning on " + serverName
        msg["From"] = "no-reply@bricocenter.it"
        msg["To"] = "supporto.brico.italy@gft.com"
        msg["X-Priority"] = "1"

        server = smtplib.SMTP('10.34.1.20', 25)
        #server.login()

        server.sendmail("no-reply@bricocenter.it", "supporto.brico.italy@gft.com", msg.as_string())
        server.quit()

def check_usage():
        df = subprocess.Popen(['df', '-hP'], stdout = subprocess.PIPE, stderr = subprocess.PIPE)
        df.wait()

        errorMessage = ""
        hasError = False
        for line in df.stdout:
                splitline = line.decode().split()

                valueColumn = splitline[4][:-1]
                if valueColumn.isdigit():
                        curVal = int(splitline[4][:-1])
                        if curVal > threshold:
                                hasError = True
                                errorMessage +=  splitline[5] + "\t" + str(curVal) + "%" + "\n"

        if hasError:
                report_mail(set_message(errorMessage))



check_usage()


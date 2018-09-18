#!/usr/bin/env python3
# coding: utf-8

import paho.mqtt.client as mqtt
import mysql.connector
import time

#Ligação à base de dados
conn = mysql.connector.connect(host='localhost',database='energy',user='remoteUser',password='password')
conn.autocommit = True
cursor=conn.cursor()

#On-connect callback. Subscreve os topicos e imprime menssagens de debug 
def on_connect(client, userdata, flags, rc):
  print("Connected with result code "+str(rc))
  client.subscribe("ready")
  client.subscribe("NodeID")
  client.subscribe("readings")

#On-message callback. Descodifica e imprime a menssagem recebida em qualquer topico que não tenha uma callback propria
def on_message_NodeID(client, userdata, msg):
  print(msg.topic+" "+str(msg.payload))
  val=(msg.payload.decode("utf-8"))
  print("Value:"+val)
  sql="SELECT Sensor.SensorID, Amperagem, ReadType, ConnType, I2CAdress, Canal from Sensor Join SensorNode on Sensor.SensorID = SensorNode.SensorID join Node on SensorNode.NodeID = Node.NodeID where Node.NodeID = %(val)s group by Sensor.SensorID";
  cursor.execute(sql, {'val':val})
  for i, row in enumerate(cursor):
   topic = str(val)+"/S"+str(i)+"/ID"
   client.publish(topic,str(row[0]))
   topic = str(val)+"/S"+str(i)+"/AMP"
   client.publish(topic,str(row[1]))
   topic = str(val)+"/S"+str(i)+"/Type"
   client.publish(topic,str(row[2]))
   topic = str(val)+"/S"+str(i)+"/Conn"
   client.publish(topic,str(row[3]))
   topic = str(val)+"/S"+str(i)+"/I2C"
   print(topic + str(row[4]))
   client.publish(topic,str(row[4]))
   topic = str(val)+"/S"+str(i)+"/Channel"
   client.publish(topic,str(row[5]))
  topic = str(val)+"/EOT"
  client.publish(topic,"EOT")
   
#Callback do topico ready.
def on_message_ready(client,userdata,msg):
 #Verifica se o MAC Address recebido existe na base de dados:
 print("ready topic")
 val=msg.payload.decode("utf-8")
 sql="SELECT MACAdress FROM Node WHERE MACAdress = %(val)s"
 cursor.execute(sql, {'val':val})
 exists = cursor.fetchone()
#Se não existir, insere na base de dados
 if not exists:
  print("not exits: "+val)
  sql="INSERT INTO Node (MACAdress) VALUES (%(val)s)"
  cursor.execute(sql, {'val':val})
 else: #Se já existir, vai à base de dados buscar os parametros necessários ao funcionamento.
  print("exists: "+val)
  sql="SELECT NodeID FROM Node WHERE MACADRESS = %(val)s"
  cursor.execute(sql, {'val':val})
  if not cursor.rowcount:
   print("error")
  else:
   for row in cursor:
    print(row[0])
    client.publish(val,row[0]) # e publica-os de volta para o cliente
	
def on_message_reading(Client,userdata,msg):
 msgStr=msg.payload.decode("utf-8")
 sql="INSERT INTO Leitura (SensorID,Leitura) VALUES (%(id)s,%(valor)s)"
 cursor.execute(sql, {'id':msgStr.split(";")[0], 'valor':msgStr.split(";")[1]})
   

#Instância o cliente e arma as callbacks.
client = mqtt.Client()
client.on_connect = on_connect
client.message_callback_add("ready",on_message_ready)
client.message_callback_add("NodeID",on_message_NodeID)
client.message_callback_add("readings",on_message_reading)

#Estabelece uma ligação ao broker
client.connect("127.0.0.1",1883,60)

#Main loop
client.loop_forever()


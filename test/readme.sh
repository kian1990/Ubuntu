javac -cp .:mysql-connector-java-8.0.20.jar test_mysql.java
java -cp .:mysql-connector-java-8.0.20.jar test_mysql
jar cvfm test_mysql.jar MANIFEST.MF test_mysql.class mysql-connector-java-8.0.20.jar

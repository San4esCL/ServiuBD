package Controlador;
import java.sql.DriverManager;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.ResultSet;
public class conexiondb {
    
    public void conectar(){
        try
        {
            //Se carga el driver JDBC
            DriverManager.registerDriver( new oracle.jdbc.driver.OracleDriver() );
             
            //nombre del servidor
            String nombre_servidor = "SERVERLINUX";
            //numero del puerto
            String numero_puerto = "1521";
            //SID
            String sid = "xe";
            //URL "jdbc:oracle:thin:@nombreServidor:numeroPuerto:SID"
            String url = "jdbc:oracle:thin:@" + nombre_servidor + ":" + numero_puerto + ":" + sid;
 
            //Nombre usuario y password
            String usuario = "SEMESTRAL";
            String password = "1234";
 
            //Obtiene la conexion
            Connection conexion = DriverManager.getConnection( url, usuario, password );
            
        }catch( Exception e ){
            e.printStackTrace();
        }
    }
}

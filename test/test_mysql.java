import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class test_mysql {

    public static void main(String[] args) {
        Connection conn = null;
        Statement stmt = null;

        try {
            // 注册 JDBC 驱动
            Class.forName("com.mysql.cj.jdbc.Driver");

            // 打开连接
            System.out.println("连接到数据库...");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "root");

            // 创建查询语句
            stmt = conn.createStatement();
            String sql = "SELECT * FROM web"; // 替换为您要查询的表名

            // 执行查询
            ResultSet rs = stmt.executeQuery(sql);

            // 打印查询结果
            while (rs.next()) {
                // 获取每一行的数据
                StringBuilder rowData = new StringBuilder();
                for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) {
                    rowData.append(rs.getString(i)).append("\t");
                }
                System.out.println(rowData.toString());
            }

        } catch (SQLException se) {
            se.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 关闭连接
            try {
                if (stmt != null) {
                    stmt.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException se) {
                se.printStackTrace();
            }
        }
    }
}


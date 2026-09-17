package lk.iu.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;


public class DBConnectionUtil {

    private static final Logger LOG = Logger.getLogger(DBConnectionUtil.class.getName());

    private static final String JNDI_DATASOURCE_NAME = "java:comp/env/jdbc/techmart";

    private static volatile DataSource cachedDataSource;

    private static final String DB_URL      = "jdbc:postgresql://localhost:5432/techmartonline";
    private static final String DB_USER     = "postgres";
    private static final String DB_PASSWORD = "#1Iu4Ma1#";

    static {
        try {
            Class.forName("org.postgresql.Driver");
            LOG.info("[DBConnectionUtil] PostgreSQL JDBC Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            LOG.severe("[DBConnectionUtil] ERROR: PostgreSQL JDBC Driver not found!");
            throw new RuntimeException("Failed to load PostgreSQL JDBC Driver", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        // Attempt JNDI DataSource lookup first (production path)
        DataSource ds = getDataSource();
        if (ds != null) {
            return ds.getConnection();
        }
        // Fallback: direct DriverManager connection (development / test path)
        LOG.fine("[DBConnectionUtil] Using DriverManager fallback (non-EE context or JNDI unavailable).");
        return DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    }

    private static DataSource getDataSource() {
        if (cachedDataSource == null) {
            synchronized (DBConnectionUtil.class) {
                if (cachedDataSource == null) {
                    try {
                        InitialContext ic = new InitialContext();
                        cachedDataSource = (DataSource) ic.lookup(JNDI_DATASOURCE_NAME);
                        LOG.info("[DBConnectionUtil] JNDI DataSource resolved: " + JNDI_DATASOURCE_NAME
                                + ". Container-managed connection pool active.");
                    } catch (NamingException e) {
                        LOG.warning("[DBConnectionUtil] JNDI DataSource lookup failed for '"
                                + JNDI_DATASOURCE_NAME + "'. "
                                + "Falling back to DriverManager. "
                                + "To enable pooled connections, declare <resource-ref> in web.xml "
                                + "and create the JDBC pool in Payara admin console. Cause: " + e.getMessage());
                    }
                }
            }
        }
        return cachedDataSource;
    }

    public static void closeConnection(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                LOG.log(Level.WARNING, "[DBConnectionUtil] Error closing connection: " + e.getMessage(), e);
            }
        }
    }
}

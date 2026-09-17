package lk.iu.util;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import java.util.logging.Logger;


public final class EjbLookupUtil {

    private static final Logger LOG = Logger.getLogger(EjbLookupUtil.class.getName());

    private static volatile InitialContext cachedContext;

    private EjbLookupUtil() {
    }

    public static <T> T lookup(Class<T> type, String beanSimpleName) throws NamingException {
        InitialContext ic = getInitialContext();
        String[] jndiNames = {
                "java:global/TechMartOnline/" + beanSimpleName + "!" + type.getName(),
                "java:module/" + beanSimpleName + "!" + type.getName(),
                "java:app/TechMartOnline/" + beanSimpleName + "!" + type.getName()
        };
        NamingException last = null;
        for (String name : jndiNames) {
            try {
                T result = type.cast(ic.lookup(name));
                LOG.fine("[EjbLookupUtil] Resolved " + type.getSimpleName() + " via: " + name);
                return result;
            } catch (NamingException e) {
                last = e;
            }
        }
        throw last != null ? last : new NamingException("EJB not found: " + type.getSimpleName());
    }

    public static <T> T lookupEnvProperty(String envEntryName, Class<T> type) throws NamingException {
        InitialContext ic = getInitialContext();
        String jndiName = "java:comp/env/" + envEntryName;
        try {
            T value = type.cast(ic.lookup(jndiName));
            LOG.fine("[EjbLookupUtil] Env property '" + envEntryName + "' = " + value);
            return value;
        } catch (NamingException e) {
            LOG.warning("[EjbLookupUtil] Env property not found: " + jndiName
                    + ". Ensure <env-entry> is declared in WEB-INF/web.xml.");
            throw e;
        }
    }

    private static InitialContext getInitialContext() throws NamingException {
        if (cachedContext == null) {
            synchronized (EjbLookupUtil.class) {
                if (cachedContext == null) {
                    cachedContext = new InitialContext();
                    LOG.fine("[EjbLookupUtil] InitialContext created and cached.");
                }
            }
        }
        return cachedContext;
    }
}

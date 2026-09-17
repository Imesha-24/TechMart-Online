package lk.iu.listener;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

import java.util.logging.Logger;

@WebListener
public class AppLifecycleListener implements ServletContextListener {

    private static final Logger LOG = Logger.getLogger(AppLifecycleListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        LOG.info("╔══════════════════════════════════════════╗");
        LOG.info("║  TechMart Application Container Starting ║");
        LOG.info("╚══════════════════════════════════════════╝");
        LOG.info("[AppLifecycle] EJB session beans deployed — @Stateless, @Stateful, @Singleton");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        LOG.info("[AppLifecycle] Application container stopped cleanly");
    }
}

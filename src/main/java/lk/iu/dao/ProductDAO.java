package lk.iu.dao;

import lk.iu.model.Product;

import java.sql.SQLException;
import java.util.List;


public interface ProductDAO {

    List<Product> findAll() throws SQLException;

    List<Product> findByCategory(String categoryName) throws SQLException;

    List<Product> findByKeyword(String keyword) throws SQLException;

    List<Product> findByCriteria(String categoryName, String keyword, String sortColumn) throws SQLException;

    Product findById(int productId) throws SQLException;

    int countAll() throws SQLException;

    List<lk.iu.model.Category> findAllCategories() throws SQLException;

    List<lk.iu.model.Brand> findAllBrands() throws SQLException;

    int insert(Product product) throws SQLException;

    void update(Product product) throws SQLException;

    void delete(int productId) throws SQLException;

    void toggleVisibility(int productId, boolean visible) throws SQLException;
}

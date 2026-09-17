package lk.iu.service;

import jakarta.ejb.Local;
import lk.iu.model.Brand;
import lk.iu.model.Category;
import lk.iu.model.Product;

import java.sql.SQLException;
import java.util.List;
import java.util.concurrent.Future;

@Local
public interface ProductService {

    List<Product> getAllProducts() throws SQLException;

    List<Product> getProductsByCategory(String categoryName) throws SQLException;

    List<Product> searchProducts(String keyword) throws SQLException;

    List<Product> getFilteredProducts(String categoryName, String keyword, String sort) throws SQLException;

    Product getProductById(int productId) throws SQLException;

    Future<List<Product>> getAllProductsAsync();

    Future<List<Product>> getFilteredProductsAsync(String categoryName, String keyword, String sort);

    int getTotalProductCount() throws SQLException;

    List<Category> getAllCategories() throws SQLException;

    List<Brand> getAllBrands() throws SQLException;

    int addProduct(Product product) throws SQLException;

    void updateProduct(Product product) throws SQLException;

    void deleteProduct(int productId) throws SQLException;

    void toggleProductVisibility(int productId, boolean visible) throws SQLException;
}

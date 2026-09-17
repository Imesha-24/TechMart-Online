package lk.iu.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Product {

    private int productId;
    private String productName;
    private String description;
    private BigDecimal price;
    private int stockQuantity;
    private String imageUrl;
    private int categoryId;
    private Timestamp createdAt;
    private int brandId;
    private int colorId;
    private String productUrl;
    private boolean visible = true; // maps to is_visible column

    // Transient fields for display (not DB columns)
    private String categoryName;
    private String brandName;
    private String colorName;
    
    // For backwards compatibility with some UI elements
    private double oldPrice;
    private double rating;
    private int reviews;

    public Product() {}

    public int getProductId() { return productId; }
    public void setProductId(int productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public int getCategoryId() { return categoryId; }
    public void setCategoryId(int categoryId) { this.categoryId = categoryId; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getBrandId() { return brandId; }
    public void setBrandId(int brandId) { this.brandId = brandId; }

    public int getColorId() { return colorId; }
    public void setColorId(int colorId) { this.colorId = colorId; }

    public String getProductUrl() { return productUrl; }
    public void setProductUrl(String productUrl) { this.productUrl = productUrl; }

    public boolean isVisible() { return visible; }
    public void setVisible(boolean visible) { this.visible = visible; }

    // Transient getters and setters
    public String getCategoryName() { return categoryName; }
    public void setCategoryName(String categoryName) { this.categoryName = categoryName; }

    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }

    public String getColorName() { return colorName; }
    public void setColorName(String colorName) { this.colorName = colorName; }
    
    public double getOldPrice() { return oldPrice; }
    public void setOldPrice(double oldPrice) { this.oldPrice = oldPrice; }
    
    public double getRating() { return rating; }
    public void setRating(double rating) { this.rating = rating; }
    
    public int getReviews() { return reviews; }
    public void setReviews(int reviews) { this.reviews = reviews; }

    @Override
    public String toString() {
        return "Product{" +
                "productId=" + productId +
                ", productName='" + productName + '\'' +
                ", price=" + price +
                ", stockQuantity=" + stockQuantity +
                '}';
    }
}

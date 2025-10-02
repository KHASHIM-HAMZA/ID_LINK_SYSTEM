package com.suza.id_link_sys.Security;


import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Map /uploads/** URL to the physical folder
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations("file:/home/gokyumi/work/idl_system/uploads/");
    }
}

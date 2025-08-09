package com.itech.itech_backend.service;

import com.itech.marketplace.dto.SLAConfigurationDto;
import com.itech.marketplace.entity.SLAConfiguration;
import java.util.List;

public interface SLAConfigurationService {
    List<SLAConfiguration> getAllConfigurations();
    SLAConfiguration createConfiguration(SLAConfigurationDto dto);
    SLAConfiguration updateConfiguration(Long id, SLAConfigurationDto dto);
}

package com.itech.itech_backend.service;

import com.itech.marketplace.dto.*;
import java.util.List;

public interface SupportAnalyticsService {
    SupportDashboardDto getDashboardOverview();
    TicketTrendsDto getTicketTrends(Integer days);
    List<AgentPerformanceDto> getAgentPerformance();
    CategoryAnalysisDto getCategoryAnalysis();
    void bulkAssignTickets(BulkAssignmentDto bulkAssignmentDto);
}

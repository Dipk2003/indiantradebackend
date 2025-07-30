package com.itech.itech_backend.controller;

import com.itech.itech_backend.model.SupportTicket;
import com.itech.itech_backend.service.SupportTicketService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/support-tickets")
@RequiredArgsConstructor
public class SupportTicketController {

    private final SupportTicketService supportTicketService;

    @PostMapping
    public ResponseEntity<SupportTicket> createSupportTicket(@RequestBody SupportTicket supportTicket) {
        SupportTicket createdTicket = supportTicketService.createSupportTicket(supportTicket);
        return ResponseEntity.ok(createdTicket);
    }

    @GetMapping
    public ResponseEntity<List<SupportTicket>> getSupportTickets() {
        List<SupportTicket> tickets = supportTicketService.getAllSupportTickets();
        return ResponseEntity.ok(tickets);
    }
}

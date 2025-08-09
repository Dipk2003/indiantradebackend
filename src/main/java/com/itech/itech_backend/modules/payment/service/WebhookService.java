package com.itech.itech_backend.service;

import org.json.JSONObject;

public interface WebhookService {
    void processRazorpayWebhook(JSONObject payload);
}


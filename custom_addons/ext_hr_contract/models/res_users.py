# -*- coding: utf-8 -*-
import uuid
from odoo import models, fields


class ResUsers(models.Model):
    _inherit = "res.users"

    api_token = fields.Char(string="API Token", readonly=True)

    def _get_api_token(self):
        token = False
        while not token:
            token = uuid.uuid4().hex
        return token
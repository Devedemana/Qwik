async getQueue(req: Request, res: Response) {
  const { cafeteriaId } = req.params;
  const orders = await MerchantService.fetchActiveOrders(cafeteriaId);
  return res.status(200).json({ success: true, data: orders });
}
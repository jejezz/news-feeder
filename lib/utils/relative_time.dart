String relativeTime(DateTime? dateTime) {
  if (dateTime == null) return '';

  final diff = DateTime.now().difference(dateTime.toLocal());
  if (diff.inMinutes < 1) return '방금 전';
  if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
  if (diff.inHours < 24) return '${diff.inHours}시간 전';
  if (diff.inDays < 7) return '${diff.inDays}일 전';

  final local = dateTime.toLocal();
  return '${local.month}월 ${local.day}일';
}

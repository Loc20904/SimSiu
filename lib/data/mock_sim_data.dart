import '../models/beautiful_sim.dart';

const mockSims = [
  BeautifulSim(
    id: 'sim-001',
    phoneNumber: '0909 888 888',
    carrier: 'Mobifone',
    type: 'Sim lục quý',
    price: 125000000,
    meaning: 'Dãy 8 tượng trưng cho phát tài, phát lộc.',
    status: SimStatus.available,
    description: 'Số dễ nhớ, phù hợp kinh doanh và xây dựng thương hiệu.',
  ),
  BeautifulSim(
    id: 'sim-002',
    phoneNumber: '0986 686 868',
    carrier: 'Viettel',
    type: 'Sim lộc phát',
    price: 28500000,
    meaning: 'Cặp 68 và 86 mang ý nghĩa lộc phát luân chuyển.',
    status: SimStatus.available,
    description: 'Cân bằng giữa độ đẹp, ngân sách và tính dễ đọc.',
  ),
  BeautifulSim(
    id: 'sim-003',
    phoneNumber: '0912 333 333',
    carrier: 'Vinaphone',
    type: 'Sim tam hoa',
    price: 42000000,
    meaning: 'Tam hoa 3 tạo cảm giác chắc chắn, bền vững.',
    status: SimStatus.available,
    description: 'Phù hợp chủ shop, tư vấn viên và người làm dịch vụ.',
  ),
  BeautifulSim(
    id: 'sim-004',
    phoneNumber: '0888 197 1999',
    carrier: 'Vietnamobile',
    type: 'Sim năm sinh',
    price: 9600000,
    meaning: 'Gắn với năm sinh 1999, dễ tạo dấu ấn cá nhân.',
    status: SimStatus.sold,
    description: 'Một lựa chọn cá nhân hóa, dễ nhớ khi giới thiệu.',
  ),
];
